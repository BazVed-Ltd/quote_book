defmodule QuoteBookWeb.SignInController do
  alias QuoteBook.Book.User
  use QuoteBookWeb, :controller

  def delete(conn, _params) do
    conn
    |> QuoteBookWeb.Helpers.Auth.log_out_user()
    |> redirect(Routes.live_path(conn, QuoteBookWeb.IndexLive))
  end

  def create(conn, %{"payload" => payload}) do
    %{"token" => silent_token, "uuid" => uuid, "user" => user} =
      Phoenix.json_library().decode!(payload)

    %{"id" => user_id} = user

    case check_user(uuid, silent_token, user_id) do
      {:ok, user_attrs} ->
        user_attrs = convert_vk_response_to_db(user_attrs)

        {:ok, user} = QuoteBook.Book.maybe_create_user(%User{}, user_attrs)

        {:ok, token, _claims} = QuoteBook.Guardian.encode_and_sign(user)

        key =
          Guardian.Plug.Keys.token_key(:default)
          |> Atom.to_string()

        conn
        |> put_resp_cookie(key, token, secure: true, sign: true)
        |> text("success")

      :error ->
        conn
        |> put_status(400)
        |> text("error")
    end
  end

  defp check_user(uuid, silent_token, user_id) do
    case VkBot.Vk.Api.exec_method(
           "auth.getProfileInfoBySilentToken",
           %{
             access_token: app_token(),
             token: silent_token,
             uuid: uuid,
             event: ""
           }
         ) do
      %{"success" => [%{"user_id" => ^user_id} = user]} -> {:ok, user}
      _error -> :error
    end
  end

  defp app_token do
    Application.get_env(:quote_book, :vk_app_token)
  end

  defp convert_vk_response_to_db(%{
         "user_id" => id,
         "first_name" => first_name,
         "last_name" => last_name,
         "photo_100" => current_photo
       }) do
    %{
      id: id,
      first_name: first_name,
      last_name: last_name,
      current_photo: current_photo
    }
  end
end
