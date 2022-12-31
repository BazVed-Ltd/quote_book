defmodule QuoteBook.Book.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :quote_id, :id

    belongs_to :from, QuoteBook.Book.User

    field :peer_id, :integer
    field :text, :string
    field :date, :integer

    field :reply_message_id, :id
    has_one :reply_message, QuoteBook.Book.Message, foreign_key: :reply_message_id

    has_many :attachments, QuoteBook.Book.Attachment

    field :fwd_from_message_id, :id
    has_many :fwd_messages, QuoteBook.Book.Message, foreign_key: :fwd_from_message_id

    field :deleted, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(message, attrs, deep \\ :infinity) do
    message
    |> changeset_nested_message(attrs, deep)
    |> validate_required_inclusion([:reply_message, :fwd_messages],
      error_message: "Вы не прикрепили сообщения, которые должны стать цитатой"
    )
    |> cast(attrs, [:peer_id, :deleted])
    |> validate_required([:peer_id])
    |> cast_quote_id()
  end

  def cast_quote_id(message) do
    peer_id = get_field(message, :peer_id)

    quote_id = (QuoteBook.Book.get_last_quote_id(peer_id) || 0) + 1

    message
    |> put_change(:quote_id, quote_id)
  end

  def changeset_nested_message(message, attrs, deep) do
    message
    |> cast(attrs, [:text, :from_id, :date])
    |> validate_required([:from_id, :date])
    |> cast_from_id_by_type()
    |> cast_assoc(:attachments)
    |> cast_nested_messages(deep)
    |> validate_required_inclusion([:text, :attachments, :reply_message, :fwd_messages])
  end

  defp cast_nested_messages(message, :infinity) do
    message
    |> cast_assoc(:reply_message, with: &__MODULE__.changeset_nested_message(&1, &2, :infinity))
    |> cast_assoc(:fwd_messages, with: &__MODULE__.changeset_nested_message(&1, &2, :infinity))
  end

  defp cast_nested_messages(message, 0) do
    message
    |> cast_assoc(:reply_message, with: &__MODULE__.changeset_nested_message(&1, &2, :stop))
    |> cast_assoc(:fwd_messages, with: &__MODULE__.changeset_nested_message(&1, &2, :stop))
  end

  defp cast_nested_messages(message, :stop) do
    message
  end

  defp cast_nested_messages(message, deep) do
    message
    |> cast_assoc(:reply_message, with: &__MODULE__.changeset_nested_message(&1, &2, deep - 1))
    |> cast_assoc(:fwd_messages, with: &__MODULE__.changeset_nested_message(&1, &2, deep - 1))
  end

  defp validate_required_inclusion(changeset, fields, opts \\ []) do
    error_message =
      Keyword.get(
        opts,
        :error_message,
        "Required at least one of these fields: #{inspect(fields)}"
      )

    if Enum.any?(fields, &present?(changeset, &1)) do
      changeset
    else
      # Add the error to the first field only since Ecto requires a field name for each error.
      add_error(changeset, hd(fields), error_message)
    end
  end

  defp present?(changeset, field) do
    value = get_field(changeset, field)
    value && value != "" && value != []
  end

  defp cast_from_id_by_type(user) do
    id = get_change(user, :from_id)

    if id < 0 do
      put_change(user, :from_id, -id + 2_000_000_000)
    else
      user
    end
  end
end
