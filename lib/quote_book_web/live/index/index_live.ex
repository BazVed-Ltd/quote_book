defmodule QuoteBookWeb.IndexLive do
  use QuoteBookWeb, :live_view

  alias QuoteBookWeb.{ChatLive, ChatListItemComponent}
  alias QuoteBook.Book

  @impl true
  def mount(_params, _session, socket) do
    chats = Book.list_chats()

    {:ok,
     socket
     |> assign(chats: chats, page_title: "Каналы")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class='mt-3 flex'>
        <div class='card mx-auto px-9'>
          <h2 class='text-center text-xl mb-4'>Каналы:</h2>
          <ul>
            <%= for chat <- @chats do %>
              <ChatListItemComponent.chat socket={@socket} chat={chat} />
            <% end %>
          </ul>
        </div>
      </div>
    """
  end
end
