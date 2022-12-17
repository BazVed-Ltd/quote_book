defmodule QuoteBook.Book.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :from_id, :integer
    field :peer_id, :integer
    field :text, :string
    field :date, :integer

    belongs_to :reply_message, QuoteBook.Book.Message

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
  end
end
