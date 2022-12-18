defmodule QuoteBook.Book do
  @moduledoc """
  The Book context.
  """

  import Ecto.Query, warn: false
  alias QuoteBook.Repo

  alias QuoteBook.Book.Message

  @raw_sql_all_messages """
  SELECT *, 0 as depth
  FROM messages
  WHERE quote_id IS NOT null
  UNION ALL
  SELECT n.*, depth + 1
  FROM messages n
  INNER JOIN message_tree fwd ON fwd.id = n.fwd_from_message_id OR fwd.id = n.reply_message_id
  """

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_quotes do
    query =
      {"message_tree", Message}
      |> recursive_ctes(true)
      |> with_cte("message_tree", as: fragment(@raw_sql_all_messages))
      |> select_merge([m], %{depth: m.depth})
      |> preload(:attachments)

    Repo.all(query)
    |> remake_tree()
  end

  def quotes_count do
    query =
      from m in Message,
        where: is_nil(m.fwd_from_message_id)

    Repo.aggregate(query, :count, :id)
  end

  @raw_sql_message_tree """
  SELECT *, 0 as depth
  FROM messages
  WHERE quote_id = ?
  UNION ALL
  SELECT n.*, depth + 1
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
      |> select_merge([m], %{depth: m.depth})
      |> preload(:attachments)

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
end
