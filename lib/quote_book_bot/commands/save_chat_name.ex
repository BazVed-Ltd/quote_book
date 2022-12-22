defmodule QuoteBookBot.Commands.SaveChatName do
  use VkBot.CommandsManager

  alias QuoteBook.Book

  defcommand event, on_text: "/чат" do
    message =
      event
      |> fetch_message()

    args =
      message
      |> Map.fetch!("text")
      |> String.split(" ")

    case args do
      [_command] ->
        {:ok, "Попробуйте /чат название чата"}

      [_command | chat_title] ->
        peer_id = Map.fetch!(message, "peer_id")
        from_id = Map.fetch!(message, "from_id")

        is_admin =
          VkBot.Api.exec_method("messages.getConversationMembers", %{"peer_id" => peer_id})
          |> Map.fetch!("items")
          |> Enum.find(%{}, fn user -> Map.fetch!(user, "member_id") == from_id end)
          |> Map.get("is_admin", false)

        change_chat_title(is_admin, peer_id, chat_title)
    end
  end

  defp change_chat_title(false = _is_user_admin?, _chat_id, _new_chat_name),
    do: {:ok, "Только для админов"}

  defp change_chat_title(true = _is_user_admin?, chat_id, new_chat_name) do
    chat = Book.get_or_new_chat(chat_id)

    Book.create_or_update_chat(chat, %{id: chat_id, title: Enum.join(new_chat_name, " ")})
    {:ok, "Готово"}
  end
end
