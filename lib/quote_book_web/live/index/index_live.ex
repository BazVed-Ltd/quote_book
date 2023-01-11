defmodule QuoteBookWeb.IndexLive do
  use QuoteBookWeb, :live_view

  alias QuoteBookWeb.ChatListItemComponent
  alias QuoteBook.Book

  @impl true
  def mount(_params, _session, socket) do
    user_id = socket.assigns.current_user

    chats =
      with false <- is_nil(user_id),
           user = Book.get_user!(user_id),
           false <- is_nil(user.chat_ids) do
        Book.get_chats(user.chat_ids)
      else
        _err -> []
      end

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
        <%= if @chats == [] do %>
          <p>Вы ещё не добавлены ни в какие чаты</p>
        <% else %>
          <ul>
            <%= for chat <- @chats do %>
              <ChatListItemComponent.chat socket={@socket} chat={chat} />
            <% end %>
          </ul>
        <% end %>
      </div>
      <%= if @current_user do %>
        <div class="w-50 mx-auto mt-5">
          <.link href={"https://vk.com/id#{@current_user}"} class="btn btn-vk-blue font-medium">
            Моя страница в ВК
          </.link>
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
