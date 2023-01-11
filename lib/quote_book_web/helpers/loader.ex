defmodule QuoteBookWeb.Helpers.Loader do
  @moduledoc """
  Загрузка полей.
  """
  import Phoenix.LiveView

  import Phoenix.Component

  use Phoenix.VerifiedRoutes, endpoint: QuoteBookWeb.Endpoint, router: QuoteBookWeb.Router

  alias QuoteBook.Book
  alias QuoteBook.Book.Chat
  alias QuoteBookWeb.Helpers.Breadcrumb

  defp redirect_on_error(socket, opts) do
    to = Keyword.get(opts, :to, "/")
    error = Keyword.get(opts, :error, "ОШИБКА!!!")

    {:halt,
     socket
     |> redirect(to: to)
     |> put_flash(:error, error)}
  end

  defp append_to_breadcrumb(socket, name, path) do
    if is_nil(socket.assigns[:breadcrumb]) do
      breadcrumb =
        Breadcrumb.new()
        |> Breadcrumb.append("Главная", "/")
        |> Breadcrumb.append(name, path)

      assign(socket, breadcrumb: breadcrumb)
    else
      breadcrumb =
        socket.assigns.breadcrumb
        |> Breadcrumb.append(name, path)

      assign(socket, breadcrumb: breadcrumb)
    end
  end

  @doc """
  Добавляет поле в `assigns`, если объект с таким названием есть в БД,
  иначе перенаправляет на верхний уровень.

  ## Доступные поля:
    - `:chat` — загружает чат.
    - `:quote` — загружает цитату, требует, чтобы перед этим был загружен чат.
  """
  def on_mount(:chat, params, _session, socket) do
    chat =
      params
      |> Map.fetch!("peer_id")
      |> Book.get_chat_by_slug_or_id()

    if is_nil(chat) do
      redirect_on_error(socket, to: ~p"/", error: "Нет такого чата.")
    else
      {:cont,
       socket
       |> assign(chat: chat)
       |> append_to_breadcrumb(chat.title || "Чат", "c/#{Chat.slug_or_id(chat)}/")}
    end
  end

  def on_mount(:quote, params, _session, socket) do
    unless Map.has_key?(socket.assigns, :chat),
      do: throw("Before assigning a quote, you need to assign chat.")

    chat = socket.assigns.chat

    with {quote_id, ""} <- params |> Map.fetch!("quote_id") |> Integer.parse(),
         quote_message when not is_nil(quote_message) <-
           Book.get_quote(chat.id, quote_id) do
      {:cont,
       socket
       |> assign(quote: quote_message)
       |> append_to_breadcrumb("Цитата", Integer.to_string(quote_id) <> "/")}
    else
      _otherwise ->
        redirect_on_error(socket,
          to: ~p"/c/#{Chat.slug_or_id(chat)}",
          error: "Нет такой цитаты"
        )
    end
  end
end
