defmodule QuoteBook.Book.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :title, :string
    field :covers, {:array, :string}, default: []

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:id, :title, :covers])
    |> validate_required([:id])
  end
end
