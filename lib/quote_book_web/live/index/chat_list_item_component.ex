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

    chat_link =
      if is_nil(chat.slug) do
        Routes.live_path(assigns.socket, ChatLive, chat.id)
      else
        Routes.live_path(assigns.socket, ChatLive, chat.slug)
      end

    ~H"""
    <li><%= live_redirect chat_link_text, to: chat_link %></li>
    """
  end
end
