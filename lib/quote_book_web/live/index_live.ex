defmodule QuoteBookWeb.IndexLive do
  use QuoteBookWeb, :live_view

  alias QuoteBook.Book
  alias QuoteBook.Book.Chat

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    chats =
      if is_nil(user) or is_nil(user.chat_ids) do
        []
      else
        Book.get_chats(user.chat_ids)
      end

    {:ok,
     socket
     |> assign(chats: chats, page_title: "Каналы")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-3 flex flex-col gap-5">
      <div class="card mx-auto px-9">
        <h2 class="text-center text-xl mb-4">Каналы:</h2>
        <%= if @chats == [] do %>
          <p>Вы ещё не добавлены ни в какие чаты</p>
        <% else %>
          <ul>
            <%= for chat <- @chats do %>
              <li>
                <.link href={~p"/c/#{Chat.slug_or_id(chat)}"}><%= chat.title || chat.id %></.link>
              </li>
            <% end %>
          </ul>
        <% end %>
      </div>
      <div class="mx-auto flex flex-col gap-5 items-center">
        <%= if @current_user do %>
          <p>Вы вошли как <%= @current_user.name %></p>
          <.link href={~p"/sign-out"} class="btn btn-vk-blue font-medium">Оформить выход</.link>
        <% else %>
          <.link href={~p"/sign-in"} class="btn btn-vk-blue font-medium">Оформить VK ID</.link>
        <% end %>
      </div>
    </div>
    """
  end
end
