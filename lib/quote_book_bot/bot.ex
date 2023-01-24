defmodule QuoteBookBot.Bot do
  @moduledoc false
  alias QuoteBookBot.Commands
  alias QuoteBookBot.Utils

  def commands do
    [
      # FIXME: It isn't middleware it's malware!!!
      Utils.SyncChat,
      # Der alarm!!!
      Commands.SaveQuote,
      Commands.RenderQuote,
      Commands.SaveChatName,
      Commands.AddCoverToChat,
      Commands.DeleteQuote,
      Commands.Help,
      Commands.PublishQuote,
      Commands.CancelPublish
    ]
  end
end
