defmodule AssetTracker.Repo.Migrations.CreateAssets do
  use Ecto.Migration

  def change do
    create table(:assets) do
      add :symbol, :string

      timestamps()
    end
  end
end
