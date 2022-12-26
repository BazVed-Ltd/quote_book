defmodule QuoteBookBot.Commands.SaveChatName do
  import VkBot.CommandsManager
  require VkBot.CommandsManager

  alias QuoteBook.Book

  defcommand request,
    predicate: [on_text: "/чат", in: :chat],
    permissions: [only_admin: true] do
    message = request.message

    args =
      message
      |> Map.fetch!("text")
      |> String.split(" ")

    case args do
      [_command] ->
        {:ok, "Попробуйте /чат название чата"}

      [_command | chat_title] ->
        peer_id = Map.fetch!(message, "peer_id")

        chat = Book.get_or_new_chat(peer_id)

        Book.create_or_update_chat(chat, %{id: peer_id, title: Enum.join(chat_title, " ")})
        {:ok, "Готово"}
    end
  end
end
