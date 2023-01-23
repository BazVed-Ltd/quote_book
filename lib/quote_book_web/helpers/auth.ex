defmodule QuoteBookWeb.Helpers.Auth do
  use QuoteBookWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  def token_key do
    Guardian.Plug.Keys.token_key(:default)
    |> Atom.to_string()
  end

  def fetch_current_user(conn, _opts) do
    with {token, conn} <- ensure_user_token(conn),
         {:ok, claims} <- QuoteBook.Guardian.decode_and_verify(token, %{"typ" => "access"}),
         {:ok, user} <- QuoteBook.Guardian.resource_from_claims(claims) do
      assign(conn, :current_user, user)
    else
      _err -> conn
    end
  end

  def ensure_user_token(conn) do
    conn = fetch_cookies(conn, signed: [token_key()])

    if token = conn.cookies[token_key()] do
      {token, put_token_in_session(conn, token)}
    else
      {nil, conn}
    end
  end

  defp put_token_in_session(conn, token) do
    conn
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
  end

  def log_out_user(conn) do
    if live_socket_id = get_session(conn, :live_socket_id) do
      QuoteBookWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> clear_session()
    |> delete_resp_cookie(token_key())
    |> redirect(to: "/")
  end

  @doc """
  Handles mounting and authenticating the current_user in LiveViews.
  ## `on_mount` arguments
    * `:mount_current_user` - Assigns current_user
      to socket assigns based on user_token, or nil if
      there's no user_token or no matching user.
    * `:ensure_authenticated` - Authenticates the user from the session,
      and assigns the current_user to socket assigns based
      on user_token.
      Redirects to login page if there's no logged user.
    * `:redirect_if_user_is_authenticated` - Authenticates the user from the session.
      Redirects to signed_in_path if there's a logged user.
  ## Examples
  Use the `on_mount` lifecycle macro in LiveViews to mount or authenticate
  the current_user:
      defmodule QuoteBookWeb.PageLive do
        use QuoteBookWeb, :live_view
        on_mount {QuoteBookWeb.UserAuth, :mount_current_user}
        ...
      end
  Or use the `live_session` of your router to invoke the on_mount callback:
      live_session :authenticated, on_mount: [{QuoteBookWeb.UserAuth, :ensure_authenticated}] do
        live "/profile", ProfileLive, :index
      end
  """
  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(session, socket)}
  end

  def on_mount(:ensure_authenticated, params, session, socket) do
    socket = mount_current_user(session, socket)

    if not is_nil(socket.assigns.current_user) or bot?(params) do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(
          :error,
          "У вас нет доступа. Для получения доступа необходимо авторизоваться."
        )
        |> Phoenix.LiveView.redirect(to: ~p"/")

      {:halt, socket}
    end
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    socket = mount_current_user(session, socket)

    if socket.assigns.current_user do
      {:halt, Phoenix.LiveView.redirect(socket, to: signed_in_path(socket))}
    else
      {:cont, socket}
    end
  end

  defp bot?(params) do
    key = Application.get_env(:quote_book, :screenshoter_key)

    params["bot"] == "true" and params["bot_key"] == key
  end

  defp mount_current_user(session, socket) do
    case session do
      %{"user_token" => user_token} ->
        Phoenix.Component.assign_new(socket, :current_user, fn ->
          {:ok, claims} = QuoteBook.Guardian.decode_and_verify(user_token, %{"typ" => "access"})
          {:ok, user} = QuoteBook.Guardian.resource_from_claims(claims)
          user
        end)

      %{} ->
        Phoenix.Component.assign_new(socket, :current_user, fn -> nil end)
    end
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.
  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if not is_nil(conn.assigns[:current_user]) or bot?(conn.query_params) do
      conn
    else
      conn
      |> put_flash(:error, "У вас нет доступа. Для получения доступа необходимо авторизоваться.")
      |> maybe_store_return_to()
      |> redirect(to: ~p"/sign-in")
      |> halt()
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: ~p"/"
end
