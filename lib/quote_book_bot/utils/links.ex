defmodule QuoteBookBot.Utils.Links do
  @moduledoc false
  alias QuoteBook.Book.Chat

  defp host do
    Application.get_env(:quote_book, :host, "localhost:4000")
  end

  @spec chat_link(Chat.t()) :: String.t()
  @doc """
  Возвращает ссылку на чат.
  """
  def chat_link(chat) do
    path = QuoteBookWeb.Router.Helpers.live_path(
      QuoteBookWeb.Endpoint,
      QuoteBookWeb.ChatLive,
      Chat.slug_or_id(chat)
    )

    host() <> path
  end

  @spec quote_link(Chat.t(), QuoteBook.Book.Message.t()) :: String.t()
  @doc """
  Возвращает красивую ссылку на цитату.
  """
  def quote_link(chat, message_quote) do
    path = QuoteBookWeb.Router.Helpers.live_path(
      QuoteBookWeb.Endpoint,
      QuoteBookWeb.QuoteLive,
      Chat.slug_or_id(chat),
      message_quote.quote_id
    )

    host() <> path
  end

  @spec quote_path(QuoteBook.Book.Message.t()) :: String.t()
  @doc """
  Возвращает путь до цитаты.
  """
  def quote_path(message_quote) do
    path = QuoteBookWeb.Router.Helpers.live_path(
      QuoteBookWeb.Endpoint,
      QuoteBookWeb.QuoteLive,
      message_quote.peer_id,
      message_quote.quote_id
    )

    path
  end
end
