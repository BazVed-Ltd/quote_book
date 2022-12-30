defmodule QuoteBookBot.Commands.Help do
  import VkBot.{CommandsManager, Request}
  require VkBot.CommandsManager

  @help_text """
  /чат — задать название чата
  /обложка — добавить обложку чату
  /сьлржалсч [глубинность] — создать цитату, если не указана глубинность, то сохраняется полное дерево сообщений
  /удалить [номер цитаты] — удалить цитату
  /удалить п — удалить последнюю цитату

  Powered by [id665045534|Grand Catware Server]
  """

  defcommand request,
    predicate: [on_text: "/помощь", in: :chat] do
    reply_message(request, @help_text, disable_mentions: 1)
  end
end