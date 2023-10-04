defmodule AssetTracker.Repo.Migrations.CreateSales do
  use Ecto.Migration

  def change do
    create table(:sales) do
      add :sell_date, :date
      add :quantity, :decimal
      add :unit_price, :decimal
      add :asset_id, references(:assets, on_delete: :nothing)

      timestamps()
    end

    create index(:sales, [:asset_id])
  end
end
