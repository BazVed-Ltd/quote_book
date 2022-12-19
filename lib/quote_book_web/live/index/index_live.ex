defmodule QuoteBookWeb.IndexLive do
  use QuoteBookWeb, :live_view

  alias QuoteBook.Book
  alias QuoteBookWeb.QuoteComponent

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(quotes: Book.list_quotes)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <QuoteComponent.quotes quotes={@quotes} />
    """
  end
end
