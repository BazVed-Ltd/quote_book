defmodule QuoteBook.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      QuoteBook.Repo,
      # Start the Telemetry supervisor
      QuoteBookWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: QuoteBook.PubSub},
      # Start the Endpoint (http/https)
      QuoteBookWeb.Endpoint,
      # Start the VK bot
      QuoteBookBot.Bot
      # Start a worker by calling: QuoteBook.Worker.start_link(arg)
      # {QuoteBook.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: QuoteBook.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    QuoteBookWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
