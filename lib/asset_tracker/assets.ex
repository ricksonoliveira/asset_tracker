defmodule AssetTracker.Assets do
  @moduledoc """
  Module for the Assets context.
  """
  import Ecto.Query, warn: false

  alias AssetTracker.{Asset, Purchase, Sale}
  alias AssetTracker.Repo

  @doc """
  Creates a new asset with the given `attrs`.

  ## Examples

      iex> AssetTracker.Assets.create_asset(%{symbol: "AAPL"})
      {:ok, %Asset{symbol: "APPL}}

      iex> AssetTracker.Assets.create_asset(%{})
      {:error, %Ecto.Changeset{}}
  """
  def create_asset(attrs \\ %{}) do
    %Asset{}
    |> Asset.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Lists all purchases for the given `asset`.

  ## Examples

      iex> AssetTracker.Assets.list_purchases(%Asset{symbol: "AAPL"})
      [%Purchase{asset_id: 1, price: 100, quantity: 10}]
  """
  def list_purchases(asset) do
    Repo.all(
      from p in Purchase,
        where: p.asset_id == ^asset.id,
        order_by: [asc: p.settle_date]
    )
  end

  @doc """
  Counts the total quantity of purchases for the given `asset_id`.

  ## Examples

      iex> AssetTracker.Assets.count_total_purchases_qty(1)
      10
  """
  def count_total_purchases_qty(asset_id) do
    Repo.one!(from p in Purchase, where: p.asset_id == ^asset_id, select: sum(p.quantity)) || 0
  end

  @doc """
  Counts the total spent for the given `asset_id`.

  ## Examples

      iex> AssetTracker.Assets.count_total_spent(1)
      1000
  """
  def count_total_spent(asset_id) do
    Repo.one!(
      from p in Purchase, where: p.asset_id == ^asset_id, select: sum(p.unit_price * p.quantity)
    ) || 0
  end

  @doc """
  Counts the total quantity of sales for the given `asset_id`.

  ## Examples

      iex> AssetTracker.Assets.count_total_sold_qty(1)
      10
  """
  def count_total_sold_qty(asset_id) do
    Repo.one!(from s in Sale, where: s.asset_id == ^asset_id, select: sum(s.quantity)) || 0
  end

  @doc """
  Creates a new purchase with the given `attrs`.

  ## Examples

      iex> AssetTracker.Assets.create_purchase(%{asset_id: 1, price: 100, quantity: 10})
      {:ok, %Purchase{asset_id: 1, price: 100, quantity: 10}}

      iex> AssetTracker.Assets.create_purchase(%{})
      {:error, %Ecto.Changeset{}}
  """
  def create_purchase(attrs \\ %{}) do
    %Purchase{}
    |> Purchase.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates the given `purchase` with the given `attrs`.

  ## Examples

      iex> AssetTracker.Assets.update_purchase(%Purchase{asset_id: 1, price: 100, quantity: 10}, %{quantity: 20})
      {:ok, %Purchase{asset_id: 1, price: 100, quantity: 20}}

      iex> AssetTracker.Assets.update_purchase(%{}, %{})
      {:error, %Ecto.Changeset{}}
  """
  def update_purchase(%Purchase{} = purchase, attrs \\ %{}) do
    purchase
    |> Purchase.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes the given `purchase`.

  ## Examples

      iex> AssetTracker.Assets.delete_purchase(%Purchase{asset_id: 1, price: 100, quantity: 10})
      {:ok, %Purchase{asset_id: 1, price: 100, quantity: 10}}

      iex> AssetTracker.Assets.delete_purchase(%{})
      {:error, %Ecto.Changeset{}}
  """
  def delete_purchase(%Purchase{} = purchase) do
    Repo.delete(purchase)
  end

  @doc """
  Creates a new sale with the given `attrs`.

  ## Examples

      iex> AssetTracker.Assets.create_sale(%{asset_id: 1, price: 100, quantity: 10})
      {:ok, %Sale{asset_id: 1, price: 100, quantity: 10}}

      iex> AssetTracker.Assets.create_sale(%{})
      {:error, %Ecto.Changeset{}}
  """
  def create_sale(attrs \\ %{}) do
    %Sale{}
    |> Sale.changeset(attrs)
    |> Repo.insert()
  end
end
