defmodule QuoteBook.Book do
  @moduledoc """
  Цитаты и всё, что с ними связано.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias QuoteBook.Repo

  alias QuoteBook.Book.{Message, User, Chat, Attachment}

  @raw_sql_all_messages """
  SELECT *
  FROM messages
  WHERE quote_id IS NOT null AND NOT deleted AND peer_id = ?
  UNION ALL
  SELECT n.*
  FROM messages n
  INNER JOIN message_tree fwd ON fwd.id = n.fwd_from_message_id OR fwd.id = n.reply_message_id
  """

  @spec list_quotes(non_neg_integer()) :: [Message.t()]
  @doc """
  Возвращает список цитат в чате.
  """
  def list_quotes(peer_id) do
    query =
      {"message_tree", Message}
      |> recursive_ctes(true)
      |> with_cte("message_tree", as: fragment(@raw_sql_all_messages, ^peer_id))
      |> preload([:attachments, :from])

    Repo.all(query)
    |> remake_tree()
    |> Enum.reverse()
  end

  @spec list_chats :: [Chat.t()]
  @doc """
  Возвращет список чатов.
  """
  def list_chats() do
    Repo.all(Chat)
  end

  @spec get_last_quote_id(non_neg_integer()) :: non_neg_integer() | nil
  @doc """
  Возвращает id последней цитаты в чате.
  Если в чате ещё нету цитат, то вернёт `nil`.
  """
  def get_last_quote_id(peer_id) do
    query =
      from(m in Message,
        where: m.peer_id == ^peer_id,
        select: max(m.quote_id)
      )

    Repo.one!(query)
  end

  @raw_sql_message_tree """
  SELECT *
  FROM messages
  WHERE peer_id = ? AND quote_id = ? AND NOT deleted
  UNION ALL
  SELECT n.*
  FROM messages n
  INNER JOIN message_tree fwd ON fwd.id = n.fwd_from_message_id OR fwd.id = n.reply_message_id
  """

  @spec get_quote(non_neg_integer(), non_neg_integer()) :: Message.t()
  @doc """
  Возвращает конкретную цитату из чата.
  """
  def get_quote(peer_id, quote_id) do
    query =
      {"message_tree", Message}
      |> recursive_ctes(true)
      |> with_cte("message_tree", as: fragment(@raw_sql_message_tree, ^peer_id, ^quote_id))
      |> preload([:attachments, :from])

    Repo.all(query)
    |> remake_tree()
    |> List.first()
  end

  @spec remake_tree([Message.t()]) :: [Message.t()]
  # doc
  #   Из списка сообщений восстанавливает дерево.
  #
  defp remake_tree(messages) do
    fwd_messages = Enum.group_by(messages, fn message -> message.fwd_from_message_id end)
    reply_messages = Enum.group_by(messages, fn message -> message.reply_message_id end)

    quotes = Enum.filter(messages, fn message -> message.quote_id end)

    quotes
    |> Enum.map(&insert_fwd_and_reply_message(&1, fwd_messages, reply_messages))
  end

  defp insert_fwd_and_reply_message(message, fwd_messages, reply_messages) do
    message =
      case Map.get(fwd_messages, message.id) do
        nil ->
          message

        msgs ->
          full_msgs =
            Enum.map(msgs, &insert_fwd_and_reply_message(&1, fwd_messages, reply_messages))

          Map.put(message, :fwd_messages, full_msgs)
      end

    case Map.get(reply_messages, message.id) do
      nil ->
        message

      [msg] ->
        full_msg = insert_fwd_and_reply_message(msg, fwd_messages, reply_messages)

        Map.put(message, :reply_message, full_msg)
    end
  end

  @spec create_quote_from_message(map(), non_neg_integer()) ::
          {:ok, Message.t()} | {:error, Ecto.Changeset.t()}
  @doc """
  Создаёт цитату из сообщения.
  """
  def create_quote_from_message(attrs \\ %{}, deep) do
    %Message{}
    |> Message.changeset(attrs, deep)
    |> Repo.insert()
  end

  ####################
  # Refactor.this do #
  ####################

  @typep sql_id :: non_neg_integer() | String.t()

  @spec maybe_delete_quote(sql_id(), sql_id(), sql_id()) ::
          :deleted | :nothing
  @doc """
  Условно удаляет цитату. Тоже, что и `maybe_delete_quote_by_admin/2`, но
  возвращает `:nothing`, если цитата не принадлежит пользователю.
  """
  def maybe_delete_quote(peer_id, quote_id, from_id) do
    query =
      from m in Message,
        where:
          m.peer_id == ^peer_id and m.quote_id == ^quote_id and m.from_id == ^from_id and
            not m.deleted

    maybe_delete_or_update_by_query(query)
  end

  @spec maybe_delete_quote_by_admin(sql_id(), sql_id()) :: :deleted | :nothing
  @doc """
  Условно удаляет цитату. Должно выполняться __только__ для администраторов чата.

  Полностью удаляет цитату в чате, если она является последней созданной
  в этом чате; если цитата  не является последней, то устанавливается флаг
  `deleted = true`. В обоих случаях вернётся `:deleted`.

  Если такой цитаты или чата не существует, то возвращается `:nothing`.
  """
  def maybe_delete_quote_by_admin(peer_id, quote_id) do
    query =
      from m in Message,
        where: m.peer_id == ^peer_id and m.quote_id == ^quote_id and not m.deleted

    maybe_delete_or_update_by_query(query)
  end

  defp maybe_delete_or_update_by_query(query) do
    query
    |> Repo.one()
    |> maybe_delete_or_update()
  end

  defp maybe_delete_or_update(nil), do: :nothing

  defp maybe_delete_or_update(quote_message) do
    last_quote_id = get_last_quote_id(quote_message.peer_id)

    if quote_message.quote_id == last_quote_id do
      Repo.delete!(quote_message)
    else
      query =
        from m in Message,
          where: m.quote_id == ^quote_message.quote_id,
          update: [set: [deleted: true]]

      Repo.update_all(query, [])
    end

    :deleted
  end

  @spec maybe_delete_last_quote(sql_id(), sql_id()) :: :deleted | :nothing
  @doc """
  То же, что и `maybe_delete_quote/3`, но удаляет последнюю цитату
  """
  def maybe_delete_last_quote(peer_id, from_id) do
    last_quote_id = get_last_quote_id(peer_id)

    query =
      from m in Message,
        where:
          m.peer_id == ^peer_id and m.quote_id == ^last_quote_id and m.from_id == ^from_id and
            not m.deleted

    maybe_delete_last_by_query(query)
  end

  @spec maybe_delete_last_quote_by_admin(sql_id()) :: :deleted | :nothing
  @doc """
  То же, что и `maybe_delete_quote_by_admin/2`, но удаляет последнюю цитату.
  """
  def maybe_delete_last_quote_by_admin(peer_id) do
    last_quote_id = get_last_quote_id(peer_id)

    query =
      from m in Message,
        where: m.peer_id == ^peer_id and m.quote_id == ^last_quote_id and not m.deleted

    maybe_delete_last_by_query(query)
  end

  defp maybe_delete_last_by_query(query) do
    query
    |> Repo.one()
    |> maybe_delete_last()
  end

  defp maybe_delete_last(nil), do: :nothing

  defp maybe_delete_last(quote_message) do
    Repo.delete!(quote_message)
    :deleted
  end

  #######
  # end #
  #######

  @spec get_users_from_messages :: [User.t()]
  def get_users_from_messages do
    query =
      from q in Message,
        left_join: u in User,
        on: q.from_id == u.id,
        select: {q.from_id, u},
        distinct: q.from_id

    Repo.all(query)
  end

  @spec insert_users(any()) :: {:ok, %{String.t() => User.t()}}
  @doc """
  Добавляет пользователей в БД одной транзакцией.
  """
  def insert_users(users) do
    users
    |> Stream.map(&User.changeset(%User{}, &1))
    |> Stream.with_index()
    |> Enum.reduce(Multi.new(), fn {user, num}, multi ->
      Multi.insert(multi, num, user)
    end)
    |> Repo.transaction()
  end

  @doc """
  Возвращает список всех пользователей.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @spec reject_exists_user([non_neg_integer()]) :: [non_neg_integer()]
  @doc """
  Отбрасывает `id` тех пользователей, что уже добавлены в БД.
  """
  def reject_exists_user(user_ids) do
    # TODO: проверить, будет ли оно работать с сообществами.
    #      Ощущение, что тут может быть баг.
    query =
      from u in User,
        where: u.id in ^user_ids,
        select: u.id

    exists_ids = Repo.all(query)

    user_ids
    |> Enum.reject(&(&1 in exists_ids))
  end

  @doc """
  Возвращает одного пользователя.

  Поднимает `Ecto.NoResultsError` если пользователя не сущетсвует.

  ## Примеры

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Создаёт пользователя.

  ## Примеры

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @spec update_user(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  @doc """
  Обновляет пользователя.

  ## Примеры

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @spec update_users([Ecto.Changeset.t()]) :: {:ok, %{String.t() => User.t()}}
  def update_users([]), do: {:ok, %{}}

  def update_users(users_changesets) do
    users_changesets
    |> Stream.with_index()
    |> Enum.reduce(Multi.new(), fn {user, num}, multi ->
      Multi.update(multi, num, user)
    end)
    |> Repo.transaction()
  end

  @doc """
  Возвращает `%Ecto.Changeset{}` для отслеживания изменений пользователя.

  ## Примеры

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @spec get_chat(non_neg_integer()) :: Chat.t() | nil
  @doc """
  Возвращает чат по `id`.

  Возвращает nil если чата не существует.

  ## Примеры

      iex> get_chat!(123)
      %Chat{}

      iex> get_chat!(456)
      nil

  """
  def get_chat(id) do
    Repo.get(Chat, id)
  end

  @spec get_chat_by_slug(String.t()) :: Chat.t() | nil
  @doc """
  Возвращает чат по `slug`.

  Возвращает nil если чата не существует.
  """
  def get_chat_by_slug(slug) do
    query =
      from c in Chat,
        where: c.slug == ^slug

    Repo.one(query)
  end

  @spec get_chat_by_slug_or_id(String.t()) :: QuoteBook.Book.Chat.t() | nil
  @doc """
  Возвращает чат по `id`, если аргумент парсится как число, иначе по `slug`.

  Возвращает nil если чата не существует.

  См. `get_chat_by_slug/1` и `get_chat/1`
  """
  def get_chat_by_slug_or_id(text) do
    case Integer.parse(text) do
      {peer_id, ""} -> get_chat(peer_id)
      _otherwise -> get_chat_by_slug(text)
    end
  end

  @spec get_or_new_chat(non_neg_integer()) :: Chat.t()
  @doc """
  Возвращает чат из БД, если существует, иначе возвращает новый.
  """
  def get_or_new_chat(id) do
    case get_chat(id) do
      nil -> %Chat{id: id}
      chat -> chat
    end
  end

  @spec create_or_update_chat(Chat.t(), map()) :: {:ok, Chat.t()} | {:error, Ecto.Changeset.t()}
  def create_or_update_chat(chat, attrs \\ %{}) do
    chat
    |> Chat.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @spec update_chat(Chat.t(), map()) :: {:ok, Chat.t()} | {:error, Ecto.Changeset.t()}
  @doc """
  Обновляет чат.

  ## Примеры

      iex> update_chat(chat, %{field: new_value})
      {:ok, %Chat{}}

      iex> update_chat(chat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat(%Chat{} = chat, attrs) do
    chat
    |> Chat.changeset(attrs)
    |> Repo.update()
  end

  @spec append_chat_cover(non_neg_integer(), String.t()) ::
          {:ok, Attachment.t()} | {:error, Ecto.Changeset.t()}
  def append_chat_cover(chat_id, cover_path) do
    chat =
      case Repo.get(Chat, chat_id) do
        nil -> Chat.changeset(%Chat{}, %{id: chat_id})
        %Chat{covers: nil} = chat -> Chat.changeset(chat, %{covers: [cover_path]})
        %Chat{covers: covers} = chat -> Chat.changeset(chat, %{covers: [cover_path | covers]})
      end

    chat = Map.update(chat, :covers, [cover_path], &[cover_path | &1])

    Repo.insert_or_update(chat)
  end
end
