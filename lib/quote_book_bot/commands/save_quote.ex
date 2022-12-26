defmodule QuoteBookBot.Commands.SaveQuote do
  import VkBot.CommandsManager
  require VkBot.CommandsManager

  require Logger

  alias QuoteBookBot.Utils.{UserLoader, Attachments, ReplyMessages}

  defcommand request,
    predicate: [on_text: "/сьлржалсч", in: :chat] do
    message =
      request.message
      |> ReplyMessages.insert_reply_message()
      |> Attachments.insert_attachments()

    chat = QuoteBook.Book.get_or_new_chat(message["peer_id"])
    QuoteBook.Book.create_or_update_chat(chat, %{})

    UserLoader.message_to_users_list(message)
    |> QuoteBook.Book.reject_exists_user()
    |> UserLoader.insert_new_users_data_to_db()

    args =
      message
      |> Map.fetch!("text")
      |> String.split(" ")

    {deep, _rest} = case args do
      [_command] -> {:infinity, ""}
      [_command, deep] -> Integer.parse("0" <> deep)
      _else -> {:infinity, ""}
    end

    case QuoteBook.Book.create_quote_from_message(message, deep) do
      {:ok, message_quote} ->
        reply_message(request, message_quote.quote_id)

      {:error, changeset} ->
        error =
          changeset.errors
          |> Enum.into(%{})
          |> Map.values()
          |> Enum.map_join("\n", &elem(&1, 0))

        if error != "" do
          reply_message(request, error)
        else
          Logger.error(inspect(changeset))
          reply_message(request, "Неизвестная ошибка. Сбрасываю ядерную боеголовку на разработчика")
        end
    end
  end
end
