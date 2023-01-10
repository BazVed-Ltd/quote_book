defmodule QuoteBookWeb.IndexLive do
  use QuoteBookWeb, :live_view

  alias QuoteBookWeb.ChatListItemComponent
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
    <div class="mt-3 flex flex-col">
      <div class="card mx-auto px-9">
        <h2 class="text-center text-xl mb-4">Каналы:</h2>
        <ul>
          <%= for chat <- @chats do %>
            <ChatListItemComponent.chat socket={@socket} chat={chat} />
          <% end %>
        </ul>
      </div>
      <%= if @current_user do %>
        <div class="w-50 mx-auto mt-5">
          <.link href={"https://vk.com/id#{@current_user}"} class="btn btn-vk-blue font-medium">Моя страница в ВК</.link>
        </div>
      <% else %>
        <div class="w-40 mx-auto mt-5">
          <.link href={~p"/sign-in"} class="btn btn-vk-blue font-medium">Оформить VK ID</.link>
        </div>
      <% end %>
    </div>
    """
  end
end
