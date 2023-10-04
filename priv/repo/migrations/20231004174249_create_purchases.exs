defmodule AssetTracker.Repo.Migrations.CreatePurchases do
  use Ecto.Migration

  def change do
    create table(:purchases) do
      add :settle_date, :date
      add :quantity, :decimal
      add :unit_price, :decimal
      add :asset_id, references(:assets, on_delete: :nothing)

      timestamps()
    end

    create index(:purchases, [:asset_id])
  end
end
