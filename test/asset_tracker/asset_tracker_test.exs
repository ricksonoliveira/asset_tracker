defmodule AssetTracker.AssetTrackerTest do
  use AssetTracker.DataCase, async: true

  alias AssetTracker
  alias AssetTracker.{Asset, Assets}

  describe "new/0" do
    test "creates a new asset instance" do
      assert %AssetTracker{} = AssetTracker.new()
    end
  end

  describe "add_purchase/5" do
    test "adds a new purchase to the given asset_tracker" do
      asset_tracker = AssetTracker.new()

      assert %AssetTracker{assets: [%Asset{symbol: symbol, purchases: [purchase]}]} =
               AssetTracker.add_purchase(asset_tracker, "TEST", Date.utc_today(), 10, 100)

      # asserting the values of the returned asset updated with the new purchase
      assert symbol == "TEST"
      assert purchase.quantity == Decimal.new(10)
      assert purchase.settle_date == Date.utc_today()
      assert purchase.unit_price == Decimal.new(100)
    end

    test "adds a new purchase to the given asset_tracker when asset already exists" do
      # creates an asset
      assert {:ok, asset} = Assets.create_asset(%{symbol: "TEST"})
      # creates an asset tracker
      assert asset_tracker =
               AssetTracker.update_asset_tracker(AssetTracker.new(), asset)

      assert %AssetTracker{assets: [%Asset{symbol: symbol}]} =
               AssetTracker.add_purchase(asset_tracker, "TEST", Date.utc_today(), 10, 100)

      assert symbol == "TEST"
    end

    test "returns a blank asset_tracker when invalid" do
      asset_tracker = AssetTracker.new()
      # passing invalid symbol
      assert %AssetTracker{assets: []} =
               AssetTracker.add_purchase(asset_tracker, 1, Date.utc_today(), 10, 100)
    end
  end

  describe "add_sale/5" do
    test "adds a new sale to the given asset_tracker and returns updated asset tracker with gain or loss" do
      asset_tracker = AssetTracker.new()

      assert %AssetTracker{assets: [%Asset{symbol: _symbol, purchases: [_purchase]}]} =
               AssetTracker.add_purchase(asset_tracker, "TEST", Date.utc_today(), 10, 100)

      assert {%AssetTracker{assets: [%Asset{symbol: symbol, sales: [sale]}]}, gain_or_loss} =
               AssetTracker.add_sale(asset_tracker, "TEST", Date.utc_today(), 10, 100)

      # asserting the values of the returned asset updated with the new purchase
      assert symbol == "TEST"
      assert sale.quantity == Decimal.new(10)
      assert sale.sell_date == Date.utc_today()
      assert sale.unit_price == Decimal.new(100)
      assert gain_or_loss == Decimal.new(0)
    end

    test "adding a sale which has losses" do
      asset_tracker = AssetTracker.new()

      # adding a purchase of 10 shares at $400
      assert %AssetTracker{assets: [%Asset{symbol: _symbol, purchases: [_purchase]}]} =
               AssetTracker.add_purchase(asset_tracker, "TEST", Date.utc_today(), 10, 400)

      # adding a sale of 5 shares at $200
      assert {%AssetTracker{assets: [%Asset{symbol: symbol, sales: [sale]}]}, gain_or_loss} =
               AssetTracker.add_sale(asset_tracker, "TEST", Date.utc_today(), 5, 200)

      # asserting the values of the returned asset updated with the new purchase
      assert symbol == "TEST"
      assert sale.quantity == Decimal.new(5)
      assert sale.sell_date == Date.utc_today()
      assert sale.unit_price == Decimal.new(200)
      # since the sale is at a lower price than the purchase, the gain_or_loss is negative
      # which means a loss
      assert gain_or_loss == Decimal.new(-1000)
    end

    test "adding sale when purchase quantity less than remaining quantity calculates gain or loss" do
      asset_tracker = AssetTracker.new()

      # adding a purchase of 10 shares at $400
      assert %AssetTracker{assets: [%Asset{symbol: _symbol, purchases: [_purchase]}]} =
               AssetTracker.add_purchase(asset_tracker, "TEST", Date.utc_today(), 5, 400)

      # adding a sale of 15 shares at $200
      assert {%AssetTracker{assets: [%Asset{symbol: symbol, sales: [sale]}]}, gain_or_loss} =
               AssetTracker.add_sale(asset_tracker, "TEST", Date.utc_today(), 10, 200)

      # asserting the values of the returned asset updated with the new purchase
      assert symbol == "TEST"
      assert sale.quantity == Decimal.new(5)
      assert sale.sell_date == Date.utc_today()
      assert sale.unit_price == Decimal.new(200)
      # since the sale is at a lower price than the purchase, the gain_or_loss is negative
      # which means a loss
      assert gain_or_loss == Decimal.new(-1000)
    end

    test "returns zero gain or loss when adding a sale without having previous purchases" do
      asset_tracker = AssetTracker.new()

      # adding a sale without having purchased previously
      assert {%AssetTracker{assets: [%Asset{symbol: symbol, sales: [sale]}]}, gain_or_loss} =
               AssetTracker.add_sale(asset_tracker, "TEST", Date.utc_today(), 10, 100)

      # asserting the values of the returned asset updated with the new purchase
      assert symbol == "TEST"
      assert sale.quantity == Decimal.new(10)
      assert sale.sell_date == Date.utc_today()
      assert sale.unit_price == Decimal.new(100)
      assert gain_or_loss == Decimal.new(0)
    end

    test "returns a blank asset_tracker when invalid" do
      asset_tracker = AssetTracker.new()
      # passing invalid symbol
      assert {%AssetTracker{assets: []}, 0} =
               AssetTracker.add_sale(asset_tracker, 1, Date.utc_today(), 10, 100)
    end
  end

  describe "unrealized_gain_or_loss/3" do
    test "caculates unrealized gain or loss correctly" do
      asset_tracker = AssetTracker.new()

      # adding a purchase of 10 shares at $100
      assert %AssetTracker{assets: [%Asset{symbol: _symbol, purchases: [_purchase]}]} =
               AssetTracker.add_purchase(asset_tracker, "TEST", Date.utc_today(), 10, 100)

      # Unrealized Gain or Loss = (market price−average cost) * total unsold quantity
      assert unrealized_gain_or_loss =
               AssetTracker.unrealized_gain_or_loss(asset_tracker, "TEST", 1100)

      assert unrealized_gain_or_loss == Decimal.new(10000)
    end

    test "calculates unrealized gain or loss with multiple purchases and a sale" do
      asset_tracker = AssetTracker.new()

      asset_tracker = AssetTracker.add_purchase(asset_tracker, "TEST", Date.utc_today(), 5, 80)
      asset_tracker = AssetTracker.add_purchase(asset_tracker, "TEST", Date.utc_today(), 10, 100)
      asset_tracker = AssetTracker.add_purchase(asset_tracker, "TEST", Date.utc_today(), 15, 120)

      {asset_tracker, _gain_or_loss} =
        AssetTracker.add_sale(asset_tracker, "TEST", Date.utc_today(), 20, 130)

      result = AssetTracker.unrealized_gain_or_loss(asset_tracker, "TEST", 150)

      assert result == Decimal.new(300)
    end
  end

  describe "get_or_create_asset/1" do
    test "returns an asset when it exists" do
      # creates an asset
      assert {:ok, _asset} = Assets.create_asset(%{symbol: "TEST"})

      assert %Asset{symbol: symbol} = AssetTracker.get_or_create_asset("TEST")

      assert symbol == "TEST"
    end

    test "creates an asset when it doesn't exists" do
      assert nil == Repo.get_by(Asset, symbol: "TEST")
      assert %Asset{symbol: symbol} = AssetTracker.get_or_create_asset("TEST")

      assert symbol == "TEST"
    end

    test "returns an error when invalid symbol" do
      assert_raise Protocol.UndefinedError, fn -> AssetTracker.get_or_create_asset("") end
    end
  end
end
