defmodule QuoteBookBot.Bot do
  @moduledoc false
  alias QuoteBookBot.Commands

  def commands do
    [
      Commands.SaveQuote,
      Commands.RenderQuote,
      Commands.SaveChatName,
      Commands.AddCoverToChat,
      Commands.DeleteQuote,
      Commands.Help,
    ]
  end
end
