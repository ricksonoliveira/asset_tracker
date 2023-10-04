defmodule AssetTracker do
  @moduledoc """
  AssetTracker keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias AssetTracker.Asset

  @doc """
  Creates a new instace of an Asset.
  """
  def new, do: %Asset{}
end
