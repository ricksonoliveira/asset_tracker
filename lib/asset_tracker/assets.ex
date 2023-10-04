defmodule AssetTracker.Assets do
  @moduledoc """
  Module for the Assets context.
  """

  alias AssetTracker.{Asset, Purchase, Sale}
  alias AssetTracker.Repo

  @doc """
  Creates a new asset with the given `attrs`.

  ## Examples

      iex> AssetTracker.Assets.create_asset(%{symbol: "AAPL"})
      {:ok, %Asset{symbol: "APPL}}

      iex> AssetTracker.Assets.create_asset(%{})
      {:error, %Ecto.Changeset{}}
  """
  def create_asset(attrs \\ %{}) do
    %Asset{}
    |> Asset.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a new purchase with the given `attrs`.

  ## Examples

      iex> AssetTracker.Assets.create_purchase(%{asset_id: 1, price: 100, quantity: 10})
      {:ok, %Purchase{asset_id: 1, price: 100, quantity: 10}}

      iex> AssetTracker.Assets.create_purchase(%{})
      {:error, %Ecto.Changeset{}}
  """
  def create_purchase(attrs \\ %{}) do
    %Purchase{}
    |> Purchase.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a new sale with the given `attrs`.

  ## Examples

      iex> AssetTracker.Assets.create_sale(%{asset_id: 1, price: 100, quantity: 10})
      {:ok, %Sale{asset_id: 1, price: 100, quantity: 10}}

      iex> AssetTracker.Assets.create_sale(%{})
      {:error, %Ecto.Changeset{}}
  """
  def create_sale(attrs \\ %{}) do
    %Sale{}
    |> Sale.changeset(attrs)
    |> Repo.insert()
  end
end
