defmodule QuoteBookBot.Commands.SaveQuote do
  use VkBot.CommandsManager

  alias QuoteBookBot.UserLoader

  defcommand event, on_text: "/сьлржалсч" do
    message =
      event
      |> fetch_message()
      |> insert_reply_message()
      |> insert_attachments()

    case QuoteBook.Book.create_quote_from_message(message) do
      {:ok, q} ->
        UserLoader.insert_new_users_data_to_db()
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
    |> Stream.map(&VkBot.Attachment.new/1)
    |> Stream.map(&VkBot.Attachment.download/1)
    |> Enum.map(&save_attachment/1)
  end

  defp calculate_hash(bitstring) do
    bitstring
    |> QuoteBookBot.BitUtils.chunks(2048)
    |> Enum.reduce(:crypto.hash_init(:sha256), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
    |> Base.encode16()
    |> String.downcase()
  end

  # TODO: Сохранять не только фото
  defp save_attachment(%VkBot.Attachment{file: binary_attachment, type: type})
       when type in ~w[photo sticker]a do
    photo = Image.open!(binary_attachment)

    hash =
      photo
      |> Image.dhash()
      |> elem(1)
      |> Base.encode16()
      |> String.downcase()

    name = hash <> ".webp"

    path = Path.join(["attachments", name])
    file_path = Path.join(["priv", "static", path])

    if not File.exists?(path) do
      # TODO: в отдельный процесс
      Image.write(photo, file_path, quality: 100)
    end

    %{type: type, path: path}
  end

  defp save_attachment(%VkBot.Attachment{file: doc, type: type, ext: ext})
       when type in ~w[doc audio audio_message]a do
    hash =
      doc
      |> calculate_hash()

    name = hash <> ".#{ext}"

    path = Path.join(["attachments", name])
    file_path = Path.join(["priv", "static", path])

    if not File.exists?(path) do
      # TODO: в отдельный процесс
      File.write!(file_path, doc)
    end

    %{type: type, path: path, ext: ext}
  end

  defp save_attachment(%VkBot.Attachment{type: :video, object: object}) do
    id = object["id"]
    owner_id = object["owner_id"]

    url = "https://vk.com/video#{owner_id}_#{id}"

    %{type: :video, path: url}
  end

  defp save_attachment(%VkBot.Attachment{type: :wall, object: object}) do
    id = object["id"]
    owner_id = object["owner_id"]

    # TODO: Сохранять репосты
    url = "https://vk.com/wall#{owner_id}_#{id}"

    %{type: :wall, path: url}
  end

  defp save_attachment(%VkBot.Attachment{type: :wall_reply, object: object}) do
    post_id = object["post_id"]
    owner_id = object["owner_id"]
    reply_id = object["id"]

    url = "https://vk.com/wall#{owner_id}_#{post_id}?reply=#{reply_id}"

    # TODO: Сохранять репосты
    %{type: :wall_reply, path: url}
  end

  defp save_attachment(%VkBot.Attachment{type: :market, object: object}) do
    id = object["id"]
    owner_id = object["owner_id"]

    url = "https://vk.com/market#{owner_id}_#{id}"

    %{type: :market, path: url}
  end

  defp save_attachment(%VkBot.Attachment{type: :market_album, object: object}) do
    id = object["id"]
    owner_id = object["owner_id"]

    url = "https://vk.com/market#{owner_id}?section=album_#{id}"

    %{type: :market, path: url}
  end
end
