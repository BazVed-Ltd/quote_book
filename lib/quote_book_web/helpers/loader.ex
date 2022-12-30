defmodule QuoteBookWeb.Helpers.Loader do
  import Phoenix.LiveView

  alias QuoteBook.Book

  def on_mount(:chat, params, _session, socket) do
    chat =
      params
      |> Map.fetch!("peer_id")
      |> Book.get_chat_by_slug_or_id()

    if is_nil(chat) do
      {:halt,
       socket
       |> push_redirect(to: "/")
       |> put_flash(:error, "ОШИБКА!!! Нет такого чата")}
    else
      {:cont, assign(socket, chat: chat)}
    end
  end
end
