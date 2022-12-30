defmodule QuoteBookBot.Utils.Links do
  defp host do
    Application.get_env(:quote_book, :host, "localhost")
  end

  def chat_link(chat) do
    path = QuoteBookWeb.Router.Helpers.live_path(
      QuoteBookWeb.Endpoint,
      QuoteBookWeb.ChatLive,
      chat.slug_or_id
    )

    host() <> path
  end

  def quote_link(chat, message_quote) do
    path = QuoteBookWeb.Router.Helpers.live_path(
      QuoteBookWeb.Endpoint,
      QuoteBookWeb.QuoteLive,
      chat.slug_or_id,
      message_quote.quote_id
    )

    host() <> path
  end
end
