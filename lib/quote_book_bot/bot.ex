defmodule QuoteBookBot.Bot do
  use VkBot

  alias QuoteBookBot.Commands

  defcommands [
    Commands.SaveQuote
  ]
end
