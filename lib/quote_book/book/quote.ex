defmodule QuoteBook.Book.Quote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "quotes" do

    belongs_to :message, QuoteBook.Book.Message

    timestamps()
  end

  @doc false
  def changeset(quote, attrs) do
    quote
    |> cast(attrs, [])
    |> cast_assoc(:message, required: true)
    |> validate_required([])
  end
end
