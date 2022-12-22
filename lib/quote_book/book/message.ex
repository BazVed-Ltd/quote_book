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
      |> changeset_without_quote_id(attrs)
      |> validate_required_inclusion([:reply_message, :fwd_messages],
        error_message: "Вы не прикрепили сообщения, которые должны стать цитатой"
      )
      |> validate_required([:peer_id])

    changeset
    |> put_change(:quote_id, get_field(changeset, :peer_id) |> QuoteBook.Book.quotes_count())
  end

  def changeset_without_quote_id(message, attrs) do
    message
    |> cast(attrs, [:text, :peer_id, :from_id, :date])
    |> validate_required([:from_id, :date])
    |> cast_assoc(:attachments)
    |> validate_required_inclusion([:text, :attachments])
    |> cast_assoc(:reply_message, with: &__MODULE__.changeset_without_quote_id/2)
    |> cast_assoc(:fwd_messages, with: &__MODULE__.changeset_without_quote_id/2)
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
end
