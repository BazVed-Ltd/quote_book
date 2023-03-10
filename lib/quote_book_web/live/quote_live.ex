defmodule QuoteBookWeb.QuoteLive do
  alias QuoteBook.Book.Chat
  use QuoteBookWeb, :live_view

  on_mount {QuoteBookWeb.Helpers.Loader, :quote}

  def mount(params, _session, socket) do
    bot? = Map.get(params, "bot") == "true"
    {:ok, assign(socket, :bot?, bot?)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto mt-5 max-w-lg">
      <div id="quote">
        <QuoteBookWeb.QuoteComponent.message_quote
          socket={@socket}
          quote={@quote}
          bot?={@bot?}
          chat_slug_or_id={Chat.slug_or_id(@chat)}
        />
      </div>
    </div>
    """
  end
end
