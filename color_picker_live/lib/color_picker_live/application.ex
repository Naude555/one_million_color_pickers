defmodule ColorPickerLive.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ColorPickerLiveWeb.Telemetry,
      ColorPickerLive.Repo,
      {DNSCluster, query: Application.get_env(:color_picker_live, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ColorPickerLive.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ColorPickerLive.Finch},
      # Start a worker by calling: ColorPickerLive.Worker.start_link(arg)
      # {ColorPickerLive.Worker, arg},
      # Start to serve requests, typically the last entry
      ColorPickerLiveWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ColorPickerLive.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ColorPickerLiveWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
