defmodule QuoteBookBot.Commands.SaveChatName do
  import VkBot.{CommandsManager, Request}
  require VkBot.CommandsManager

  alias QuoteBookBot.Utils.Links
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
        reply_message(request, "Попробуйте /чат название чата")

      [_command | chat_title] ->
        peer_id = Map.fetch!(message, "peer_id")

        chat = Book.get_or_new_chat(peer_id)

        responser =
          Book.create_or_update_chat(chat, %{id: peer_id, title: Enum.join(chat_title, " ")})
          |> parse_ecto_response()

        responser.(request)
    end
  end

  defp parse_ecto_response({:ok, chat}) do
    message =
      if is_nil(chat.slug) do
        "Название чата изменено, но сделать красивую ссылку не получилось."
      else
        "Название чата изменено"
      end <> "\nНовая ссылка на чат #{Links.chat_link(chat)}"

    fn request -> reply_message(request, message) end
  end

  defp parse_ecto_response({:error, changeset}) do
    message =
      changeset.errors
      |> Enum.into(%{})
      |> Map.values()
      |> Enum.map_join("\n", &elem(&1, 0))

    fn request -> reply_message(request, message) end
  end
end
