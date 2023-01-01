defmodule QuoteBookBot.Utils.Links do
  alias QuoteBook.Book.Chat

  defp host do
    Application.get_env(:quote_book, :host, "localhost")
  end

  def chat_link(chat) do
    path = QuoteBookWeb.Router.Helpers.live_path(
      QuoteBookWeb.Endpoint,
      QuoteBookWeb.ChatLive,
      Chat.slug_or_id(chat)
    )

    host() <> path
  end

  def quote_link(chat, message_quote) do
    path = QuoteBookWeb.Router.Helpers.live_path(
      QuoteBookWeb.Endpoint,
      QuoteBookWeb.QuoteLive,
      Chat.slug_or_id(chat),
      message_quote.quote_id
    )

    host() <> path
  end
end
