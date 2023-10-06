defmodule AssetTracker do
  @moduledoc """
  AssetTracker keeps the contexts that define your domain
  and business logic.
  This module provides a Tail Call Optimized (TCO) approach to the FIFO (First-In-First-Out) calculation method.
  TCO ensures that our recursive function calls won't exhaust the stack even for large datasets.
  Check out this approach in the function `calculate_fifo/3`.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias AssetTracker.{Asset, Assets, Repo}

  defstruct assets: []

  @doc """
  Creates a new instace of an Asset.

  ## Examples

      iex> AssetTracker.new()
      %AssetTracker{assets: []}
  """
  def new, do: %AssetTracker{}

  @doc """
  Adds a new purchase to the given `asset_tracker` for the given `symbol`.

  ## Examples

      iex> AssetTracker.add_purchase(%AssetTracker{}, "AAPL", Date.utc_today(), 10, 100)
      %AssetTracker{
        assets: [
          %Asset{
            id: 1,
            purchases: [
              %Purchase{
                asset_id: 1,
                price: 100,
                quantity: 10,
                settle_date: ~D[2020-01-01]
              }
            ],
            sales: [],
            symbol: "AAPL"
          }
        ]
      }
  """
  def add_purchase(%AssetTracker{} = asset_tracker, symbol, settle_date, quantity, unit_price)
      when is_binary(symbol) and is_integer(quantity) and is_integer(unit_price) do
    # Gets the asset from the database or creates a new one
    with %Asset{} = asset <- get_asset(asset_tracker, symbol),
         # Creates a new purchase and preloads the asset with purchases and sales
         %Asset{} = asset <-
           create_purchase_and_get_preloaded_asset(
             asset,
             %{
               asset_id: asset.id,
               settle_date: settle_date,
               quantity: quantity,
               unit_price: unit_price
             }
           ) do
      # updates the asset tracker with the found or created asset
      update_asset_tracker(asset_tracker, asset)
    end
  end

  def add_purchase(_asset_tracker, _symbol, _settle_date, _quantity, _unit_price), do: new()

  @doc """
  Adds a new sale to the given `asset_tracker` for the given `symbol`.

  ## Examples

      iex> AssetTracker.add_sale(%AssetTracker{}, "AAPL", Date.utc_today(), 10, 100)
      {%AssetTracker{
        assets: [
          %Asset{
            id: 1,
            purchases: [
              %Purchase{
                asset_id: 1,
                price: 100,
                quantity: 10,
                settle_date: ~D[2020-01-01]
              }
            ],
            sales: [
              %Sale{
                asset_id: 1,
                price: 100,
                quantity: 10,
                sell_date: ~D[2020-01-01]
              }
            ],
            symbol: "AAPL"
          }
        ]
      }, 0}
  """
  def add_sale(%AssetTracker{} = asset_tracker, symbol, sell_date, quantity, unit_price)
      when is_binary(symbol) and is_integer(quantity) and is_integer(unit_price) do
    # Gets the asset from the database or creates a new one
    with %Asset{} = asset <- get_asset(asset_tracker, symbol),
         purchases <-
           Assets.list_purchases(asset)
           |> Enum.sort_by(& &1.settle_date),
         # Handling the FIFO principle
         # Read more at: https://en.wikipedia.org/wiki/FIFO_and_LIFO_accounting#FIFO_principle
         # The params we need to calculate the gain or loss is the remaining quantity along with unit_price
         {remaining_qty, gain_or_loss, modifications} <-
           calculate_fifo(purchases, quantity, unit_price),
         {:ok, _} <- apply_fifo_modifications(modifications),
         %Asset{} = asset <-
           create_sale_and_get_preloaded_asset(
             asset,
             %{
               asset_id: asset.id,
               sell_date: sell_date,
               quantity: Decimal.sub(quantity, remaining_qty),
               unit_price: unit_price
             }
           ) do
      # updates the asset tracker with the found or created asset
      {update_asset_tracker(asset_tracker, asset), gain_or_loss}
    end
  end

  def add_sale(_asset_tracker, _symbol, _settle_date, _quantity, _unit_price), do: {new(), 0}

  @doc """
  Calculates the unrealized gain or loss for the given `asset_tracker` and `symbol`.
  This is the gain or loss that would be realized if the asset was sold at the given `market_price`.

  ## Examples
      iex> AssetTracker.unrealized_gain_or_loss(%AssetTracker{}, "AAPL", 1100)
      10000
  """
  def unrealized_gain_or_loss(asset_tracker, symbol, market_price) do
    asset = get_asset(asset_tracker, symbol)

    total_unsold_qty = Assets.count_total_purchases_qty(asset.id)

    # Total spent on unsold purchases
    total_spent_on_unsold = Assets.count_total_spent(asset.id)

    # Average cost = total spent on unsold purchases / total unsold quantity
    average_cost = Decimal.div(total_spent_on_unsold, total_unsold_qty)

    # Unrealized gain or loss = (market price - average cost) * total unsold quantity
    Decimal.sub(market_price, average_cost)
    |> Decimal.mult(total_unsold_qty)
  end

  def update_asset_tracker(asset_tracker, asset) do
    # Add this purchase to the asset's list of purchases and update the tracker's asset list
    updated_assets =
      asset_tracker.assets
      |> Enum.filter(fn a -> a.symbol != asset.symbol end)
      |> Enum.concat([asset])

    # Return updated AssetTracker
    %AssetTracker{asset_tracker | assets: updated_assets}
  end

  defp calculate_gain_or_loss(purchase_price, sell_price, quantity) do
    # Gain or loss = (sell price - purchase price) * quantity
    Decimal.sub(sell_price, purchase_price)
    |> Decimal.mult(quantity)
  end

  # When there are no previous purchases, return zero remaining quantity and zero gain/loss.
  defp calculate_fifo([], _quantity, _unit_price), do: {Decimal.new(0), Decimal.new(0), []}

  # Calculate FIFO for given purchases, sale quantity, and unit price.
  defp calculate_fifo(purchases, quantity, unit_price)
       when is_list(purchases) and is_integer(quantity) and is_integer(unit_price) do
    # Initiate the recursive TCO call
    do_calculate_fifo(
      purchases,
      Decimal.new(quantity),
      Decimal.new(unit_price),
      # Initial accumulated gain or loss
      Decimal.new(0),
      # Initial modifications (updates or deletes for each purchase)
      []
    )
  end

  # Base case for the recursion: When all purchases have been processed.
  defp do_calculate_fifo([], remaining_qty, _unit_price, acc_gain_or_loss, mods),
    do: {remaining_qty, acc_gain_or_loss, Enum.reverse(mods)}

  # Recursive TCO function to calculate gain/loss based on FIFO for each purchase.
  defp do_calculate_fifo([purchase | t], remaining_qty, unit_price, acc_gain_or_loss, mods) do
    # When the current purchase quantity is less than the sale quantity
    if Decimal.compare(purchase.quantity, remaining_qty) == :lt do
      new_gain_or_loss =
        calculate_gain_or_loss(purchase.unit_price, unit_price, purchase.quantity)

      # Recursive call with updated parameters after processing the current purchase
      do_calculate_fifo(
        t,
        Decimal.sub(remaining_qty, purchase.quantity),
        unit_price,
        Decimal.add(acc_gain_or_loss, new_gain_or_loss),
        [{:delete, purchase} | mods]
      )
    else
      # When the current purchase quantity is greater than or equal to the sale quantity
      new_gain_or_loss = calculate_gain_or_loss(purchase.unit_price, unit_price, remaining_qty)

      # Recursive call with updated parameters after processing part of the current purchase
      do_calculate_fifo(
        t,
        Decimal.new(0),
        unit_price,
        Decimal.add(acc_gain_or_loss, new_gain_or_loss),
        [{:update, purchase, Decimal.sub(purchase.quantity, remaining_qty)} | mods]
      )
    end
  end

  defp apply_fifo_modifications(modifications) do
    # Apply modifications to the database
    Enum.map(modifications, fn mod ->
      case mod do
        {:delete, purchase} ->
          Assets.delete_purchase(purchase)

        {:update, purchase, new_qty} ->
          Assets.update_purchase(purchase, %{quantity: new_qty})
      end
    end)
    # Check if any of the modifications failed
    |> Enum.any?(&match?({:error, _}, &1))
    # handles errors gracefully if any of the modifications failed
    |> then(fn result ->
      if result do
        {:error, "Failed to apply FIFO modifications"}
      else
        {:ok, "FIFO modifications applied successfully"}
      end
    end)
  end

  defp create_purchase_and_get_preloaded_asset(asset, params) do
    Assets.create_purchase(%{
      asset_id: asset.id,
      settle_date: params[:settle_date],
      quantity: params[:quantity],
      unit_price: params[:unit_price]
    })

    Repo.preload(asset, [:purchases, :sales])
  end

  defp create_sale_and_get_preloaded_asset(asset, params) do
    Assets.create_sale(%{
      asset_id: asset.id,
      sell_date: params[:sell_date],
      quantity: params[:quantity],
      unit_price: params[:unit_price]
    })

    Repo.preload(asset, [:purchases, :sales])
  end

  defp get_asset(asset_tracker, symbol) do
    Enum.find(asset_tracker.assets, fn a -> a.symbol == symbol end) ||
      get_or_create_asset(symbol)
  end

  @doc """
  Gets the asset from the database or creates a new one.

  ## Examples

      iex> AssetTracker.get_or_create_asset("AAPL")
      %Asset{
        __meta__: #Ecto.Schema.Metadata<:loaded, "assets">,
        id: 1,
        purchases: [],
        sales: [],
        symbol: "AAPL"
      }

      iex> AssetTracker.get_or_create_asset("")
      Protocol.UndefinedError "symbol cant't be blank"
  """
  def get_or_create_asset(symbol) do
    case Repo.get_by(Asset, symbol: symbol) do
      nil ->
        # Creates a new asset
        case Assets.create_asset(%{symbol: symbol}) do
          {:ok, asset} -> asset
          {:error, reason} -> raise "Failed to create asset: #{reason}"
        end

      %Asset{} = asset ->
        asset
    end
  end
end
