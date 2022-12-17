defmodule QuoteBook.Book.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :from_id, :integer
    field :peer_id, :integer
    field :text, :string
    field :datetime, :integer

    belongs_to :reply_message, QuoteBook.Book.Message

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text, :peer_id, :from_id, :datetime])
    |> validate_required([:text, :peer_id, :from_id, :datetime])
    |> cast_assoc(:reply_message)
  end
end
