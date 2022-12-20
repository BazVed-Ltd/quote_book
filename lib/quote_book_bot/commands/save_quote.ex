defmodule QuoteBookBot.Commands.SaveQuote do
  use VkBot.CommandsManager

  alias QuoteBookBot.Utils.{UserLoader, Attachments, ReplyMessages}

  defcommand event, on_text: "/сьлржалсч" do
    message =
      event
      |> fetch_message()
      |> ReplyMessages.insert_reply_message()
      |> Attachments.insert_attachments()

    case QuoteBook.Book.create_quote_from_message(message) do
      {:ok, q} ->
        UserLoader.insert_new_users_data_to_db()
        {:ok, Integer.to_string(q.quote_id)}

      {:error, changeset} ->
        error =
          changeset.errors
          |> Enum.into(%{})
          |> Map.values()
          |> Enum.map(&elem(&1, 0))
          |> Enum.join("\n")

        {:ok, error}
    end
  end
end
