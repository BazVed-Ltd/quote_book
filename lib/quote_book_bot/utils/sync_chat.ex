defmodule QuoteBookBot.Utils.SyncChat do
  @sync_every_in_seconds 30 * 60

  def predicate(request) do
    message = request.message
    chat_id = message["peer_id"]

    if chat_id != message["from_id"] do
      maybe_sync(chat_id)
    end

    false
  end

  def maybe_sync(chat_id) do
    chat = QuoteBook.Book.get_chat(chat_id)

    unless is_nil(chat) do
      synced_at =
        if is_nil(chat.synced_at) do
          nil
        else
          DateTime.from_naive!(chat.synced_at, "Etc/UTC")
        end

      now = DateTime.now!("Etc/UTC")

      if is_nil(synced_at) or DateTime.diff(now, synced_at) > @sync_every_in_seconds do
        :ok = sync(chat_id)

        {:ok, _} = QuoteBook.Book.update_chat(chat, %{synced_at: NaiveDateTime.utc_now()})
      end
    end
  end

  defp sync(chat_id) do
    last_members =
      QuoteBook.Book.get_chat_members(chat_id)
      |> Enum.map(fn user -> user.id end)
      |> MapSet.new()

    members_now =
      VkBot.Api.exec_method("messages.getConversationMembers", %{
        peer_id: chat_id
      })
      |> Map.fetch!("items")
      |> Enum.map(fn user -> user["member_id"] end)
      |> Enum.reject(fn id -> id < 0 end)
      |> MapSet.new()

    users_in =
      MapSet.difference(members_now, last_members)
      |> Enum.to_list()

    users_out =
      MapSet.difference(last_members, members_now)
      |> Enum.to_list()

    QuoteBook.Book.remove_users_from_chat(chat_id, users_out)
    QuoteBook.Book.append_users_to_chat(chat_id, users_in)
    :ok
  end
end
