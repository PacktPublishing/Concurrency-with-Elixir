defmodule Rarebit.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Broadway pipelines
      Rarebit.Pipelines.Simple,
      # Standard Phoenix stuff below...
      RarebitWeb.Telemetry,
      Rarebit.Repo,
      {DNSCluster, query: Application.get_env(:rarebit, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Rarebit.PubSub},
      # Start to serve requests, typically the last entry
      RarebitWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Rarebit.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RarebitWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
