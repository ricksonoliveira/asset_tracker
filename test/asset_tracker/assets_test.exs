defmodule AssetTracker.AssetsTest do
  @moduledoc """
  Tests for the Assets context.
  """

  alias AssetTracker.Purchase
  use AssetTracker.DataCase, async: true

  alias AssetTracker.Assets

  setup do
    # creates an asset
    asset = %{symbol: "AAPL"}
    assert {:ok, asset} = Assets.create_asset(asset)

    {:ok, asset: asset}
  end

  describe "purchases contexts: " do
    test "creates a purchase", %{asset: asset} do
      attrs = %{
        asset_id: asset.id,
        unit_price: 100,
        quantity: 10,
        settle_date: Date.utc_today()
      }

      {:ok, purchase} = Assets.create_purchase(attrs)

      assert purchase.id
      assert purchase.asset_id == asset.id
      assert purchase.unit_price == Decimal.new(100)
      assert purchase.quantity == Decimal.new(10)
    end

    test "creates a purchase fails when invalid" do
      assert {:error, _} = Assets.create_purchase(%{})
    end

    test "updates a purchase", %{asset: asset} do
      # creates a purchase
      purchase = %{
        asset_id: asset.id,
        unit_price: 100,
        quantity: 10,
        settle_date: Date.utc_today()
      }

      assert {:ok, purchase} = Assets.create_purchase(purchase)
      assert purchase.quantity == Decimal.new(10)

      assert {:ok, purchase_updated} = Assets.update_purchase(purchase, %{quantity: 20})
      assert purchase_updated.quantity == Decimal.new(20)
    end

    test "updates a purchase fails when invalid", %{asset: asset} do
      # creates a purchase
      purchase = %{
        asset_id: asset.id,
        unit_price: 100,
        quantity: 10,
        settle_date: Date.utc_today()
      }

      assert {:ok, purchase} = Assets.create_purchase(purchase)
      assert purchase.quantity == Decimal.new(10)

      # updates the purchase with invalid quantity
      assert {:error, _} = Assets.update_purchase(purchase, %{quantity: "invalid"})
    end

    test "lists all purchases for the given asset", %{asset: asset} do
      # creates a purchase
      purchase = %{
        asset_id: asset.id,
        unit_price: 100,
        quantity: 10,
        settle_date: Date.utc_today()
      }

      assert {:ok, _} = Assets.create_purchase(purchase)

      assert [purchase] = Assets.list_purchases(asset)
      assert purchase.asset_id == asset.id
    end

    test "deletes a purchase", %{asset: asset} do
      # creates a purchase
      purchase = %{
        asset_id: asset.id,
        unit_price: 100,
        quantity: 10,
        settle_date: Date.utc_today()
      }

      assert {:ok, purchase} = Assets.create_purchase(purchase)

      assert {:ok, _} = Assets.delete_purchase(purchase)
      assert_raise Ecto.NoResultsError, fn -> Repo.get!(Purchase, purchase.id) end
    end

    test "count_total_purchases_qty/1", %{asset: asset} do
      # asserts returns 0 when no purchases
      assert 0 == Assets.count_total_purchases_qty(asset.id)

      # creates a purchase
      purchase = %{
        asset_id: asset.id,
        unit_price: 100,
        quantity: 10,
        settle_date: Date.utc_today()
      }

      assert {:ok, _} = Assets.create_purchase(purchase)

      assert Decimal.new(10) == Assets.count_total_purchases_qty(asset.id)
    end

    test "count_total_spent/1", %{asset: asset} do
      # asserts returns 0 when nothing spent
      assert 0 == Assets.count_total_spent(asset.id)

      # creates a purchase
      purchase = %{
        asset_id: asset.id,
        unit_price: 100,
        quantity: 10,
        settle_date: Date.utc_today()
      }

      assert {:ok, _} = Assets.create_purchase(purchase)

      assert Decimal.new(1000) == Assets.count_total_spent(asset.id)
    end
  end

  describe "sales context: " do
    test "creates a sale", %{asset: asset} do
      attrs = %{asset_id: asset.id, unit_price: 100, quantity: 10, sell_date: Date.utc_today()}

      {:ok, sale} = Assets.create_sale(attrs)

      assert sale.id
      assert sale.asset_id == asset.id
      assert sale.unit_price == Decimal.new(100)
      assert sale.quantity == Decimal.new(10)
    end

    test "creates a sale fails when invalid" do
      attrs = %{unit_price: nil, quantity: nil, sell_date: nil}

      assert {:error, _} = Assets.create_sale(attrs)
    end

    test "count_total_sold_qty/1", %{asset: asset} do
      # asserts returns 0 when no sales
      assert 0 == Assets.count_total_sold_qty(asset.id)

      # creates a sale
      sale = %{
        asset_id: asset.id,
        unit_price: 100,
        quantity: 10,
        sell_date: Date.utc_today()
      }

      assert {:ok, _} = Assets.create_sale(sale)

      assert Decimal.new(10) == Assets.count_total_sold_qty(asset.id)
    end
  end
end
