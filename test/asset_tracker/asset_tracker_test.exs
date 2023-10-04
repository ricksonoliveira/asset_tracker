defmodule AssetTracker.AssetTrackerTest do
  use AssetTracker.DataCase, async: true

  alias AssetTracker
  alias AssetTracker.Asset

  describe "new/0" do
    test "creates a new asset" do
      assert %Asset{} = AssetTracker.new()
    end
  end
end
