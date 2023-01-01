defmodule QuoteBookWeb.ChatListItemComponent do
  use QuoteBookWeb, :component

  alias QuoteBook.Book.Chat

  def chat(assigns) do
    ~H"""
    <li>
      <.link href={~p"/c/#{Chat.slug_or_id(@chat)}"}><%= @chat.title || @chat.id %></.link>
    </li>
    """
  end
end
