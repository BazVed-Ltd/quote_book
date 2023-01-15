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

  def update_exists_users do
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
end
