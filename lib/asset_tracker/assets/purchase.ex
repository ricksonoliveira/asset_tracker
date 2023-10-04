defmodule AssetTracker.Purchase do
  alias AssetTracker.Asset
  use Ecto.Schema
  import Ecto.Changeset

  schema "purchases" do
    field :settle_date, :date
    field :quantity, :decimal
    field :unit_price, :decimal

    belongs_to :asset, Asset

    timestamps()
  end

  @doc false
  def changeset(purchase, attrs) do
    purchase
    |> cast(attrs, [:settle_date, :quantity, :unit_price, :asset_id])
    |> validate_required([:settle_date, :quantity, :unit_price, :asset_id])
  end
end
