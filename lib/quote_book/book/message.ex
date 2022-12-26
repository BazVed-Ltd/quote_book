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

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    changeset =
      message
      |> changeset_nested_message(attrs)
      |> validate_required_inclusion([:reply_message, :fwd_messages],
        error_message: "Вы не прикрепили сообщения, которые должны стать цитатой"
      )
      |> cast(attrs, [:peer_id])
      |> validate_required([:peer_id])

    changeset
    |> put_change(:quote_id, get_field(changeset, :peer_id) |> QuoteBook.Book.quotes_count())
  end

  def changeset_nested_message(message, attrs) do
    message
    |> cast(attrs, [:text, :from_id, :date])
    |> validate_required([:from_id, :date])
    |> cast_from_id_by_type()
    |> cast_assoc(:attachments)
    |> cast_assoc(:reply_message, with: &__MODULE__.changeset_nested_message/2)
    |> cast_assoc(:fwd_messages, with: &__MODULE__.changeset_nested_message/2)
    |> validate_required_inclusion([:text, :attachments, :reply_message, :fwd_messages])
  end

  defp validate_required_inclusion(changeset, fields, opts \\ []) do
    error_message =
      Keyword.get(opts, :error_message, "Required at least one of these fields: #{inspect(fields)}")

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
