defmodule QuoteBookWeb.IndexLive do
  use QuoteBookWeb, :live_view

  alias QuoteBook.Book
  alias QuoteBook.Book.Chat
  alias QuoteBookWeb.{ChatLive, FeedLive, SignInLive}

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
        <ul>
          <li>
            <%= live_redirect "Общая лента",
                    to: Routes.live_path(assigns.socket, FeedLive) %>
          </li>
          <%= for chat <- @chats do %>
            <li>
              <%= live_redirect chat.title || chat.id,
                    to: Routes.live_path(assigns.socket, ChatLive, Chat.slug_or_id(chat)) %>
            </li>
          <% end %>
        </ul>
      </div>
      <div class="mx-auto flex flex-col gap-5 items-center">
        <%= if @current_user do %>
          <p>Вы вошли как <%= @current_user.name %></p>
          <%= link "Оформить выход",
                to: Routes.sign_in_path(assigns.socket, :delete),
                class: "btn btn-vk-blue font-medium" %>
        <% else %>
          <%= live_redirect "Оформить VK ID",
                to: Routes.live_path(assigns.socket, SignInLive),
                class: "btn btn-vk-blue font-medium" %>
        <% end %>
      </div>
    </div>
    """
  end
end
