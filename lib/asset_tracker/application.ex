defmodule AssetTracker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      AssetTracker.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: AssetTracker.PubSub},
      # Start Finch
      {Finch, name: AssetTracker.Finch},
      # Start a worker by calling: AssetTracker.Worker.start_link(arg)
      # {AssetTracker.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AssetTracker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
