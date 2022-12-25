defmodule QuoteBookBot.Commands.SaveQuote do
  use VkBot.CommandsManager

  require Logger

  alias QuoteBookBot.Utils.{UserLoader, Attachments, ReplyMessages}

  defcommand event, on_text: "/сьлржалсч", in: :chat do
    message =
      event
      |> fetch_message()
      |> ReplyMessages.insert_reply_message()
      |> Attachments.insert_attachments()

    chat = QuoteBook.Book.get_or_new_chat(message["peer_id"])
    QuoteBook.Book.create_or_update_chat(chat, %{})


    UserLoader.message_to_users_list(message)
    |> QuoteBook.Book.reject_exists_user()
    |> UserLoader.insert_new_users_data_to_db()

    case QuoteBook.Book.create_quote_from_message(message) do
      {:ok, q} ->
        {:ok, Integer.to_string(q.quote_id)}

      {:error, changeset} ->
        error =
          changeset.errors
          |> Enum.into(%{})
          |> Map.values()
          |> Enum.map_join("\n", &elem(&1, 0))

        if error != "" do
          {:ok, error}
        else
          Logger.error(inspect(changeset))
          {:ok, "Неизвестная ошибка. Сбрасываю ядерную боеголовку на разработчика"}
        end
    end
  end
end
