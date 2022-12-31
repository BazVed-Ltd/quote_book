defmodule QuoteBookBot.Utils.UserLoader do
  alias QuoteBook.Book

  # TODO: Лучше скачивать аватарки
  def insert_new_users_data_to_db(user_ids) do
    {group_ids, user_ids} = Enum.split_with(user_ids, &(&1 > 2_000_000_000))

    {:ok, users} =
      get_users(user_ids)
      |> photo_100_to_curernt_photo()
      |> Book.insert_users()

    {:ok, groups} =
      get_groups(group_ids)
      |> photo_100_to_curernt_photo()
      |> negate_id()
      |> Book.insert_users()

    {:ok, Map.merge(users, groups)}
  end

  def message_to_users_list(message) do
    do_message_to_users_list(message)
    |> Enum.uniq()
  end

  defp do_message_to_users_list(nil), do: []

  defp do_message_to_users_list(%{"from_id" => from_id} = message) do
    reply_message = Map.get(message, "reply_message")
    fwd_messages = Map.get(message, "fwd_messages", [])

    id =
      if from_id > 0 do
        from_id
      else
        -from_id + 2_000_000_000
      end

    List.flatten([
      id,
      do_message_to_users_list(reply_message)
      | Enum.map(fwd_messages, &do_message_to_users_list/1)
    ])
  end

  def update_exists_users() do
    users_list = Book.list_users()

    users_list
    |> Stream.map(&Map.fetch!(&1, :id))
    |> Stream.chunk_every(200)
    |> Enum.map(&get_users/1)
    |> List.flatten()
    |> photo_100_to_curernt_photo()
    |> Stream.zip(users_list)
    |> Stream.map(&Book.change_user(elem(&1, 1), elem(&1, 0)))
    |> Enum.filter(fn
      %{changes: changes} when changes == %{} -> false
      _ -> true
    end)
    |> Book.update_users()
  end

  defp get_users([]), do: []

  defp get_users(user_ids) do
    VkBot.Api.exec_method("users.get", %{
      "user_ids" => Enum.join(user_ids, ","),
      "fields" => "photo_100"
    })
  end

  defp get_groups([]), do: []

  defp get_groups(group_ids) do
    group_ids = Enum.map(group_ids, fn id -> id - 2_000_000_000 end)

    VkBot.Api.exec_method("groups.getById", %{
      "group_ids" => Enum.join(group_ids, ","),
      "fields" => "photo_100"
    })
  end

  defp negate_id(groups) do
    groups
    |> Stream.map(fn g -> Map.update!(g, "id", &Kernel.-/1) end)
  end

  defp photo_100_to_curernt_photo(users) do
    users
    |> Stream.map(&Map.put(&1, "current_photo", &1["photo_100"]))
  end
end
