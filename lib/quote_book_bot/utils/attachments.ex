defmodule QuoteBookBot.Utils.Attachments do
  alias QuoteBookBot.Utils.{MapExtensions, BitstringExtensions}

  @attachments_dir Application.compile_env!(:quote_book, :attachments_directory)

  def insert_attachments(nil), do: nil

  def insert_attachments(message) do
    message
    |> Map.update!("attachments", &load_attachments/1)
    |> MapExtensions.update_or_nothing("reply_message", &insert_attachments/1)
    |> MapExtensions.update_or_nothing("fwd_messages", fn m ->
      Enum.map(m, &insert_attachments/1)
    end)
  end

  def load_attachments(attachments) do
    attachments
    |> Enum.map(&load_attachment/1)
  end

  def load_attachment(attachment) do
    attachment
    |> VkBot.Attachment.new(gif_as_mp4: true)
    |> VkBot.Attachment.download()
    |> save_attachment()
  end

  defp save_attachment(%VkBot.Attachment{file: binary_attachment, type: type})
       when type in ~w[photo sticker]a do
    photo = Image.open!(binary_attachment)

    hash =
      binary_attachment
      |> BitstringExtensions.chunks(2048)
      |> Enum.reduce(:crypto.hash_init(:sha256), &:crypto.hash_update(&2, &1))
      |> :crypto.hash_final()
      |> Base.encode16()
      |> String.downcase()

    name = hash <> ".webp"

    path = Path.join(["attachments", name])
    file_path = Path.join([@attachments_dir, name])

    if not File.exists?(path) do
      Image.write!(photo, file_path)
    end

    %{type: type, path: path}
  end

  defp save_attachment(%VkBot.Attachment{file: doc, type: type, ext: ext})
       when type in ~w[doc audio audio_message]a do
    hash =
      doc
      |> BitstringExtensions.chunks(2048)
      |> Enum.reduce(:crypto.hash_init(:sha256), &:crypto.hash_update(&2, &1))
      |> :crypto.hash_final()
      |> Base.encode16()
      |> String.downcase()

    name = hash <> ".#{ext}"

    path = Path.join(["attachments", name])
    file_path = Path.join([@attachments_dir, name])

    if not File.exists?(path) do
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
