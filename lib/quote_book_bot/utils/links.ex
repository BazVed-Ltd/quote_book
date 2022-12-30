defmodule QuoteBookBot.Utils.Links do
  defp host do
    Application.get_env(:quote_book, :host, "localhost")
  end

  def chat_link(chat) do
    slug_or_id =
      if is_nil(chat.slug) do
        chat.id
      else
        chat.slug
      end

    path = QuoteBookWeb.Router.Helpers.live_path(
      QuoteBookWeb.Endpoint,
      QuoteBookWeb.ChatLive,
      slug_or_id
    )

    host() <> path
  end

  def quote_link(chat, message_quote) do
    slug_or_id =
      if is_nil(chat.slug) do
        chat.id
      else
        chat.slug
      end

    path = QuoteBookWeb.Router.Helpers.live_path(
      QuoteBookWeb.Endpoint,
      QuoteBookWeb.QuoteLive,
      slug_or_id,
      message_quote.quote_id
    )

    host() <> path
  end
end
