defmodule QuoteBook.Book.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  alias QuoteBook.Book.Chat.TitleSlug

  schema "chats" do
    field :title, :string
    field :covers, {:array, :string}, default: []

    field :slug, TitleSlug.Type

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:id, :title, :covers])
    |> validate_required([:id])
    |> unique_constraint(:title, message: "Чат с таким названием уже существует. Попробуйте другое")
    |> validate_length(:title, min: 1, max: 24, message: "Название чата не должно превышать 24 символа")
    |> validate_format(:title, ~r/^[^0-9].*$/, message: "Название не может начинается с цифры")
    |> TitleSlug.maybe_generate_slug()
    |> TitleSlug.unique_constraint(message: "Чат с таким названием уже существует. Попробуйте другое")
  end
end
