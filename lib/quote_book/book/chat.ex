defmodule QuoteBook.Book.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:id, :title])
    |> validate_required([:id, :title])
  end
end
