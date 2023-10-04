defmodule AssetTracker.AssetsTest do
  @moduledoc """
  Tests for the Assets context.
  """

  use AssetTracker.DataCase, async: true

  alias AssetTracker.Assets

  setup do
    # creates an asset
    asset = %{symbol: "AAPL"}
    assert {:ok, asset} = Assets.create_asset(asset)

    {:ok, asset: asset}
  end

  describe "create_purchase/1" do
    test "creates a purchase", %{asset: asset} do
      attrs = %{asset_id: asset.id, unit_price: 100, quantity: 10, settle_date: Date.utc_today()}

      {:ok, purchase} = Assets.create_purchase(attrs)

      assert purchase.id
      assert purchase.asset_id == asset.id
      assert purchase.unit_price == Decimal.new(100)
      assert purchase.quantity == Decimal.new(10)
    end
  end

  describe "create_sale/1" do
    test "creates a sale", %{asset: asset} do
      attrs = %{asset_id: asset.id, unit_price: 100, quantity: 10, sell_date: Date.utc_today()}

      {:ok, sale} = Assets.create_sale(attrs)

      assert sale.id
      assert sale.asset_id == asset.id
      assert sale.unit_price == Decimal.new(100)
      assert sale.quantity == Decimal.new(10)
    end
  end
end
