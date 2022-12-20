defmodule QuoteBookWeb.IndexLive do
  use QuoteBookWeb, :live_view

  alias QuoteBookWeb.ChatLive
  alias QuoteBook.Book

  @impl true
  def mount(_params, _session, socket) do
    chats = Book.list_chats()
    {:ok, socket |> assign(chats: chats)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class='mt-3 flex'>
        <div class='card mx-auto px-9'>
          <h2 class='text-center text-xl mb-4'>Каналы:</h2>
          <ul>
            <%= for {id, chat} <- @chats do %>
              <li><%= live_redirect (if is_nil(chat) do id else chat.title end), to: Routes.live_path(@socket, ChatLive, id) %></li>
            <% end %>
          </ul>
        </div>
      </div>
    """
  end
end
