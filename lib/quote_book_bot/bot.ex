defmodule QuoteBookBot.Bot do
  alias QuoteBookBot.Commands

  def commands do
    [
      Commands.SaveQuote,
      Commands.SaveChatName,
      Commands.AddCoverToChat
    ]
  end
end
