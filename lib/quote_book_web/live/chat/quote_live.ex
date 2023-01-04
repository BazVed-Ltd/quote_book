defmodule QuoteBookWeb.QuoteLive do
  use QuoteBookWeb, :live_view

  on_mount {QuoteBookWeb.Helpers.Loader, :chat}
  on_mount {QuoteBookWeb.Helpers.Loader, :quote}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto mt-5 max-w-lg">
      <div id="quote">
        <QuoteBookWeb.QuoteComponent.message_quote quote={@quote} />
      </div>
    </div>
    """
  end
end
