defmodule QuoteBookWeb.ChatListItemComponent do
  use QuoteBookWeb, :component

  alias QuoteBookWeb.ChatLive

  def chat(assigns) do
    chat = assigns.chat

    chat_link_text =
      if is_nil(chat.title) do
        chat.id
      else
        chat.title
      end

    chat_link = Routes.live_path(assigns.socket, ChatLive, chat.slug_or_id)

    ~H"""
    <li><%= live_redirect chat_link_text, to: chat_link %></li>
    """
  end
end
