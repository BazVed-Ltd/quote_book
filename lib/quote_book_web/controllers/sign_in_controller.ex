defmodule QuoteBookWeb.SignInController do
  alias QuoteBook.Book.User
  use QuoteBookWeb, :controller

  def delete(conn, _params) do
    conn
    |> QuoteBookWeb.Helpers.Auth.log_out_user()
    |> redirect(Routes.live_path(conn, QuoteBookWeb.IndexLive))
  end

  def create(conn, %{"payload" => payload}) do
    with {:ok, data} <- Phoenix.json_library().decode(payload),
         %{"token" => silent_token, "uuid" => uuid, "user" => user} <-
           data,
         {:ok, user_id} <- Map.fetch(user, "id"),
         {:ok, user_attrs} <- check_user(uuid, silent_token, user_id),
         user_attrs = convert_vk_response_to_db(user_attrs),
         {:ok, user} <- QuoteBook.Book.maybe_create_user(%User{}, user_attrs),
         {:ok, token, _claims} <- QuoteBook.Guardian.encode_and_sign(user) do
      conn
      |> put_resp_cookie(token_key(), token, secure: true, sign: true)
      |> text("OK")
    else
      {:error, error} when is_binary(error) ->
        conn
        |> put_status(400)
        |> text(error)

      {:error, _error} ->
        conn
        |> put_status(400)
        |> text("Сообщите об ошибке вашему администратору.")

      _error ->
        conn
        |> put_status(400)
        |> text("Неверные данные. Попробуйте ещё раз.")
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
      _error -> {:error, "Токен недействителен."}
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

  defp token_key do
    Guardian.Plug.Keys.token_key(:default)
    |> Atom.to_string()
  end
end
