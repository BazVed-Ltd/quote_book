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
    message
    |> changeset_without_quote_id(attrs)
    |> validate_required([:peer_id])
    |> put_change(:quote_id, get_field(message, :peer_id)|> QuoteBook.Book.quotes_count())
  end

  def changeset_without_quote_id(message, attrs) do
    message
    |> cast(attrs, [:text, :peer_id, :from_id, :date])
    |> validate_required([:from_id, :date]) # TODO: required attachments or text
    |> cast_assoc(:attachments)
    |> cast_assoc(:reply_message, with: &__MODULE__.changeset_without_quote_id/2)
    |> cast_assoc(:fwd_messages, with: &__MODULE__.changeset_without_quote_id/2)
  end
end
