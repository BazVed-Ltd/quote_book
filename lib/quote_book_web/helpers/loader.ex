defmodule QuoteBookWeb.Helpers.Loader do
  @moduledoc """
  Загрузка полей.
  """
  import Phoenix.LiveView

  alias QuoteBook.Book
  alias QuoteBook.Book.Chat
  import QuoteBookWeb.Helpers.Breadcrumb, only: [append_to_socket: 3]

  defp redirect_on_error(socket, opts) do
    to = Keyword.get(opts, :to, "/")
    error = Keyword.get(opts, :error, "ОШИБКА!!!")

    {:halt,
     socket
     |> push_redirect(to: to)
     |> put_flash(:error, error)}
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
      redirect_on_error(socket, to: "/", error: "Нет такого чата.")
    else
      {:cont,
       socket
       |> assign(chat: chat)
       |> append_to_socket(chat.title || "Чат", "c/#{Chat.slug_or_id(chat)}/")}
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
       |> append_to_socket("Цитата", Integer.to_string(quote_id) <> "/")}
    else
      _otherwise ->
        redirect_on_error(socket,
          to: "/c/#{Chat.slug_or_id(chat)}",
          error: "Нет такой цитаты"
        )
    end
  end
end
