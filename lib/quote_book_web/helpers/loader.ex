defmodule QuoteBookWeb.Helpers.Loader do
  import Phoenix.LiveView

  import Phoenix.Component

  use Phoenix.VerifiedRoutes, endpoint: QuoteBookWeb.Endpoint, router: QuoteBookWeb.Router

  alias QuoteBook.Book

  defp redirect_on_error(socket, opts) do
    to = Keyword.get(opts, :to, "/")
    error = Keyword.get(opts, :error, "ОШИБКА!!!")

    {:halt,
     socket
     |> redirect(to: to)
     |> put_flash(:error, error)}
  end

  def on_mount(:chat, params, _session, socket) do
    chat =
      params
      |> Map.fetch!("peer_id")
      |> Book.get_chat_by_slug_or_id()

    if is_nil(chat) do
      redirect_on_error(socket, to: ~p"/", error: "Нет такого чата")
    else
      {:cont, assign(socket, chat: chat)}
    end
  end

  def on_mount(:quote, params, _session, socket) do
    unless Map.has_key?(socket.assigns, :chat),
      do: throw("Before assigning a quote, you need to assign chat")

    with {quote_id, ""} <- params |> Map.fetch!("quote_id") |> Integer.parse(),
         quote_message when not is_nil(quote_message) <-
           Book.get_quote(socket.assigns.chat.id, quote_id) do
      {:cont,
       socket
       |> assign(quote: quote_message)}
    else
      # FIXME: Исправить путь до цитаты
      _otherwise ->
        redirect_on_error(socket,
          to: ~p"/#{socket.assigns.chat.id}",
          error: "Нет такой цитаты"
        )
    end
  end
end
