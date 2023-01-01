defmodule QuoteBookWeb.ChatListItemComponent do
  use QuoteBookWeb, :component

  def chat(assigns) do
    ~H"""
    <li>
      <.link href={~p"/c/#{@chat.slug_or_id}"}><%= @chat.title || @chat.id %></.link>
    </li>
    """
  end
end
