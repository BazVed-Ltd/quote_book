defmodule QuoteBookBot.Commands.SaveQuote do
  use VkBot.CommandsManager

  defcommand event, on_text: "/сьлржалсч" do
    message =
      event
      |> fetch_message()
      |> insert_reply_message()
      |> insert_attachments()

    case QuoteBook.Book.create_quote_from_message(message) do
      {:ok, q} ->
        {:ok, Integer.to_string(q.quote_id)}

      err ->
        IO.inspect(err)
        {:ok, "АШИПКА!!!"}
    end
  end

  defp insert_reply_message(%{"reply_message" => reply_message} = message) do
    conversation_message_id = reply_message["conversation_message_id"]
    peer_id = message["peer_id"]

    result_message =
      VkBot.Api.exec_method("messages.getByConversationMessageId", %{
        "conversation_message_ids" => conversation_message_id,
        "peer_id" => peer_id
      })
      |> Map.fetch!("items")
      |> List.first()
      |> insert_reply_message()

    message
    |> Map.put("reply_message", result_message)
  end

  defp insert_reply_message(message) do
    message
  end

  defp insert_attachments(nil), do: nil

  defp insert_attachments(message) do
    message
    |> Map.update!("attachments", &load_attachments/1)
    |> update_or_nothing("reply_message", &insert_attachments/1)
    |> update_or_nothing("fwd_messages", fn m -> Enum.map(m, &insert_attachments/1) end)
  end

  # Literally `Map.update/4`, but without adding default value.
  defp update_or_nothing(map, key, fun) do
    case Map.fetch(map, key) do
      {:ok, value} -> Map.put(map, key, fun.(value))
      :error -> map
    end
  end

  defp load_attachments(attachments) do
    attachments
    |> Stream.map(&VkBot.Attachments.download/1)
    |> Enum.map(&save_attachment_on_disk/1)
  end

  # TODO: Сохранять не только фото
  defp save_attachment_on_disk(%{"file" => binary_attachment, "type" => "photo"}) do
    photo = Image.open!(binary_attachment)

    hash =
      photo
      |> Image.dhash()
      |> elem(1)
      |> Base.encode64()

    name = hash <> ".webp"

    path = Path.join(["attachments", name])
    file_path = Path.join(["priv", "static", path])

    if not File.exists?(path) do
      # TODO: в отдельный процесс
      Image.write(photo, file_path, quality: 100)
    end

    %{"type" => "photo", "path" => path}
  end
end
