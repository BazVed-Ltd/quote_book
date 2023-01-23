defmodule QuoteBookWeb.FeedLive do
  use QuoteBookWeb, :live_view

  alias QuoteBook.Book
  alias QuoteBookWeb.FeedLive
  alias QuoteBookWeb.QuoteComponent

  import QuoteBookWeb.Helpers.Breadcrumb, only: [append_to_socket: 3]

  @impl true
  def mount(_params, _session, socket) do
    quotes = Book.list_published_quotes()
    {:ok, socket
    |> assign(:quotes, quotes)
    |> append_to_socket("Лента", Routes.live_path(socket, FeedLive)) }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-5">
        <h1 class="text-xl text-center">Лента</h1>
    </div>
    <div class="mt-5">
      <QuoteComponent.quotes socket={@socket} quotes={@quotes} type={:published} />
    </div>
    """
  end
end
