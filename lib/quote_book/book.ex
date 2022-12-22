defmodule QuoteBook.Book do
  @moduledoc """
  The Book context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias QuoteBook.Repo

  alias QuoteBook.Book.{Message, User, Chat}

  @raw_sql_all_messages """
  SELECT *
  FROM messages
  WHERE quote_id IS NOT null AND peer_id = ?
  UNION ALL
  SELECT n.*
  FROM messages n
  INNER JOIN message_tree fwd ON fwd.id = n.fwd_from_message_id OR fwd.id = n.reply_message_id
  """

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_quotes(peer_id) do
    query =
      {"message_tree", Message}
      |> recursive_ctes(true)
      |> with_cte("message_tree", as: fragment(@raw_sql_all_messages, ^peer_id))
      |> preload([:attachments, :from])
      |> reverse_order()

    Repo.all(query)
    |> remake_tree()
  end

  def list_chats() do
    Repo.all(Chat)
  end

  def quotes_count(peer_id) do
    query =
      from m in Message,
        where: m.peer_id == ^peer_id

    Repo.aggregate(query, :count, :quote_id)
  end

  @raw_sql_message_tree """
  SELECT *
  FROM messages
  WHERE quote_id = ?
  UNION ALL
  SELECT n.*
  FROM messages n
  INNER JOIN message_tree fwd ON fwd.id = n.fwd_from_message_id OR fwd.id = n.reply_message_id
  """

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_quote!(id) do
    query =
      {"message_tree", Message}
      |> recursive_ctes(true)
      |> with_cte("message_tree", as: fragment(@raw_sql_message_tree, ^id))
      |> preload([:attachments, :from])

    Repo.all(query)
    |> remake_tree()
    |> List.first()
  end

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

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_quote_from_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  alias QuoteBook.Book.Attachment

  @doc """
  Returns the list of attachments.

  ## Examples

      iex> list_attachments()
      [%Attachment{}, ...]

  """
  def list_attachments do
    Repo.all(Attachment)
  end

  @doc """
  Gets a single attachment.

  Raises `Ecto.NoResultsError` if the Attachment does not exist.

  ## Examples

      iex> get_attachment!(123)
      %Attachment{}

      iex> get_attachment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_attachment!(id), do: Repo.get!(Attachment, id)

  @doc """
  Creates a attachment.

  ## Examples

      iex> create_attachment(%{field: value})
      {:ok, %Attachment{}}

      iex> create_attachment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_attachment(attrs \\ %{}) do
    %Attachment{}
    |> Attachment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a attachment.

  ## Examples

      iex> update_attachment(attachment, %{field: new_value})
      {:ok, %Attachment{}}

      iex> update_attachment(attachment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_attachment(%Attachment{} = attachment, attrs) do
    attachment
    |> Attachment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a attachment.

  ## Examples

      iex> delete_attachment(attachment)
      {:ok, %Attachment{}}

      iex> delete_attachment(attachment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_attachment(%Attachment{} = attachment) do
    Repo.delete(attachment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking attachment changes.

  ## Examples

      iex> change_attachment(attachment)
      %Ecto.Changeset{data: %Attachment{}}

  """
  def change_attachment(%Attachment{} = attachment, attrs \\ %{}) do
    Attachment.changeset(attachment, attrs)
  end

  def get_users_from_messages do
    query =
      from q in Message,
        left_join: u in User,
        on: q.from_id == u.id,
        select: {q.from_id, u},
        distinct: q.from_id

    Repo.all(query)
  end

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
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

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

  @doc """
  Updates a user.

  ## Examples

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
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Gets a single chat.

  Raises `Ecto.NoResultsError` if the Chat does not exist.

  ## Examples

      iex> get_chat!(123)
      %Chat{}

      iex> get_chat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat!(id), do: Repo.get!(Chat, id)

  def get_or_new_chat(id) do
    case Repo.get(Chat, id) do
      nil -> %Chat{}
      chat -> chat
    end
  end

  @doc """
  Creates a chat.

  ## Examples

      iex> create_chat(%{field: value})
      {:ok, %Chat{}}

      iex> create_chat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat!(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert!()
  end

  def create_or_update_chat(chat, attrs \\ %{}) do
    chat
    |> Chat.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Updates a chat.

  ## Examples

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

  @doc """
  Deletes a chat.

  ## Examples

      iex> delete_chat(chat)
      {:ok, %Chat{}}

      iex> delete_chat(chat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat(%Chat{} = chat) do
    Repo.delete(chat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat changes.

  ## Examples

      iex> change_chat(chat)
      %Ecto.Changeset{data: %Chat{}}

  """
  def change_chat(%Chat{} = chat, attrs \\ %{}) do
    Chat.changeset(chat, attrs)
  end

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
