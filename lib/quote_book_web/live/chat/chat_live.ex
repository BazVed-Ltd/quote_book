defmodule QuoteBookWeb.ChatLive do
  use QuoteBookWeb, :live_view

  alias QuoteBook.Book
  alias QuoteBookWeb.QuoteComponent

  @impl true
  def mount(params, _session, socket) do
    peer_id = params |> Map.fetch!("peer_id") |> String.to_integer()
    quotes = Book.list_quotes(peer_id)
    {:ok, socket |> assign(quotes: quotes)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <QuoteComponent.quotes quotes={@quotes} />
    """
  end
end
