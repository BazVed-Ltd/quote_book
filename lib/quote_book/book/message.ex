defmodule QuoteBook.Book.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :quote_id, :id
    field :from_id, :integer
    field :peer_id, :integer
    field :text, :string
    field :date, :integer

    field :depth, :integer, load_in_query: false

    field :reply_message_id, :id
    has_one :reply_message, QuoteBook.Book.Message,
    foreign_key: :reply_message_id

    has_many :attachments, QuoteBook.Book.Attachment

    field :fwd_from_message_id, :id
    has_many :fwd_messages, QuoteBook.Book.Message,
      foreign_key: :fwd_from_message_id

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text, :peer_id, :from_id, :date])
    |> validate_required([:text, :peer_id, :from_id, :date])
    |> cast_assoc(:reply_message)
    |> cast_assoc(:attachments)
    |> cast_assoc(:fwd_messages)
    |> cast_quote_id()
  end

  defp cast_quote_id(message) do
    message
    |> put_change(:quote_id, QuoteBook.Book.count_quotes)
  end
end
