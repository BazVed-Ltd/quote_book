defmodule QuoteBookBot.Utils.UserLoader do
  @moduledoc """
  Загрузка пользователей.
  """
  alias QuoteBook.Book

  # TODO: Лучше скачивать аватарки
  @spec insert_new_users_data_to_db([non_neg_integer()]) :: {:ok, map()}
  @doc """
  Возвращает `{:ok, _inserted_users}`, если все пользователи добавлены успешно.

  Поднимает исключение, если не получилось добавить хотя бы одного пользователя.

  Чтобы не было коллизий с сообществами, у них `id` увеличен на `2_000_000_000`.
  """
  def insert_new_users_data_to_db(ids) do
    {:ok, inserted} =
      Book.reject_exists_user(ids)
      |> get_users()
      |> Book.insert_users()

    {:ok, inserted}
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
    db_users = Book.list_users()

    vk_users =
      db_users
      |> Stream.map(&Map.fetch!(&1, :id))
      |> Stream.chunk_every(200)
      |> Enum.map(&get_users/1)
      |> List.flatten()

    for vk_user <- vk_users, db_user <- db_users, db_user.id == vk_user["id"] do
      {db_user, vk_user}
    end
    |> Stream.map(&Book.change_user(elem(&1, 0), elem(&1, 1)))
    |> Enum.filter(fn
      %{changes: changes} when changes == %{} -> false
      _ -> true
    end)
    |> Book.update_users()
  end

  def get_users([]), do: []

  def get_users(ids) do
    code = generate_get_users_code(ids)

    VkBot.Api.exec_method("execute", %{"code" => code})
  end

  @get_users_code """
  var input = [%1];

  var users = [];
  var groups = [];

  var i = 0;
  var inputLength = input.length;
  while (i < inputLength) {
    if (input[i] < 2000000000) {
      users.push(input[i]);
    } else {
      groups.push(input[i] - 2000000000);
    }

    i = i + 1;
  }

  var results = [];

  users = API.users.get({ user_ids: users, fields: "photo_100" });

  i = 0;
  var usersLength = users.length;
  while (i < usersLength) {
    results.push({
      id: users[i].id,
      name: users[i].first_name + " " + users[i].last_name,
      current_photo: users[i].photo_100,
    });
    i = i + 1;
  }

  if (groups.length != 0) {
    groups = API.groups.getById({ group_ids: groups, fields: "photo_100" });

    i = 0;
    var groupsLength = groups.length;
    while (i < groupsLength) {
      results.push({
        id: groups[i].id + 2000000000,
        name: groups[i].name,
        current_photo: groups[i].photo_100,
      });
      i = i + 1;
    }
  } else {
    groups = [];
  }

  return results;
  """

  defp generate_get_users_code(ids) do
    joined_ids = Enum.join(ids, ", ")
    String.replace(@get_users_code, "%1", joined_ids)
  end

  def sync_chats_members do
    users =
      Book.list_users()
      |> Stream.reject(fn user -> user.id > 2_000_000_000 end)

    chat_chunks =
      Book.list_chats()
      |> Stream.chunk_every(25)

    users
    |> Enum.map(fn user ->
      chats =
        Stream.map(chat_chunks, fn chat_chunk ->
          chat_chunk_ids = Enum.map(chat_chunk, &Map.fetch!(&1, :id))
          get_member_chats(user.id, chat_chunk_ids)
        end)
        |> Enum.concat()

      QuoteBook.Book.change_user(user, %{chat_ids: chats})
    end)
    |> Book.update_users()
  end

  def get_member_chats(user_id, chat_ids) do
    code = generate_get_member_chats_code(user_id, chat_ids)
    VkBot.Api.exec_method("execute", %{"code" => code})
  end

  @get_member_chats_code """
  var user = %1;
  var conversations = [%2];

  var result = [];

  var conversationsLength = conversations.length;
  var i = 0;
  while (i < conversationsLength) {
    var conversation = API.messages.getConversationMembers({peer_id: conversations[i]});

    var itemsLength = conversation.items.length;
    var j = 0;
    while (j < itemsLength) {
      if (conversation.items[j].member_id == user) {
        result.push(conversations[i]);
      }
      j = j + 1;
    }
    i = i + 1;
  }

  return result;
  """

  defp generate_get_member_chats_code(user, chat_ids) do
    joined_ids = Enum.join(chat_ids, ", ")

    @get_member_chats_code
    |> String.replace("%1", to_string(user))
    |> String.replace("%2", joined_ids)
  end
end
