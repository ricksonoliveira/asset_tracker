defmodule AssetTracker.Asset do
  alias AssetTracker.Sale
  alias AssetTracker.Purchase

  use Ecto.Schema
  import Ecto.Changeset

  schema "assets" do
    field :symbol, :string

    has_many :purchases, Purchase
    has_many :sales, Sale

    timestamps()
  end

  @doc false
  def changeset(asset, attrs) do
    asset
    |> cast(attrs, [:symbol])
    |> validate_required([:symbol])
  end
end
