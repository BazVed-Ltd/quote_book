defmodule QuoteBookWeb.Router do
  use QuoteBookWeb, :router

  alias QuoteBookWeb.Helpers.Auth
  import Auth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {QuoteBookWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", QuoteBookWeb do
    pipe_through [:browser]

    live_session :index,
      on_mount: [{Auth, :mount_current_user}] do
      live "/", IndexLive
    end

    live "/feed", FeedLive
  end

  scope "/", QuoteBookWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :sign_in,
      on_mount: [{QuoteBookWeb.Helpers.Auth, :redirect_if_user_is_authenticated}] do
      live "/sign-in", SignInLive
    end
  end

  scope "/", QuoteBookWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/sign-out", SignInController, :delete

    live_session :chats,
      on_mount: [
        {Auth, :ensure_authenticated},
        {QuoteBookWeb.Helpers.Loader, :chat},
        QuoteBookWeb.Helpers.ChatAccess
      ] do
      live "/c/:peer_id", ChatLive
      live "/c/:peer_id/:quote_id", QuoteLive
    end
  end

  scope "/", QuoteBookWeb do
    pipe_through [:api]
    post "/sign-in", SignInController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", QuoteBookWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: QuoteBookWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
