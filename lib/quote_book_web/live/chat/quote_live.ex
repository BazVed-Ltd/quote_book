defmodule QuoteBookWeb.QuoteLive do
  use QuoteBookWeb, :live_view

  on_mount {QuoteBookWeb.Helpers.Loader, :chat}
  on_mount {QuoteBookWeb.Helpers.Loader, :quote}

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    IO.inspect(assigns.quote)
    ~H"""
    <div class="flex flex-col max-w-lg px-3 sm:px-0 mx-auto my-5">
      <QuoteBookWeb.QuoteComponent.message_quote quote={@quote} />
    </div>
    """
  end
end
