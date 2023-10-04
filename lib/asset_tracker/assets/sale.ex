defmodule AssetTracker.Sale do
  alias AssetTracker.Asset
  use Ecto.Schema
  import Ecto.Changeset

  schema "sales" do
    field :sell_date, :date
    field :quantity, :decimal
    field :unit_price, :decimal

    belongs_to :asset, Asset

    timestamps()
  end

  @doc false
  def changeset(sale, attrs) do
    sale
    |> cast(attrs, [:sell_date, :quantity, :unit_price, :asset_id])
    |> validate_required([:sell_date, :quantity, :unit_price, :asset_id])
  end
end
