defmodule QuoteBookWeb.FeedLive do
  use QuoteBookWeb, :live_view

  alias QuoteBook.Book
  alias QuoteBookWeb.QuoteComponent

  @impl true
  def mount(_params, _session, socket) do
    quotes = Book.list_published_quotes()
    {:ok, assign(socket, :quotes, quotes)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-5">
        <h1 class="text-xl text-center">Лента</h1>
    </div>
    <div class="mt-5">
      <QuoteComponent.quotes quotes={@quotes} type={:published} />
    </div>
    """
  end
end
