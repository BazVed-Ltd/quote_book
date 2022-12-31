defmodule QuoteBook.Book.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  alias QuoteBook.Book.Chat.TitleSlug

  schema "chats" do
    field :title, :string
    field :covers, {:array, :string}, default: []

    field :slug, TitleSlug.Type

    field :slug_or_id, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:id, :title, :covers])
    |> validate_required([:id])
    |> unique_constraint(:title, message: "Чат с таким названием уже существует. Попробуйте другое")
    |> validate_length(:title, min: 1, max: 24, message: "Название чата не должно превышать 24 символа")
    |> validate_format(:title, ~r/\p{L}/u, message: "Название должно содержать хотя бы одну букву")
    |> TitleSlug.maybe_generate_slug()
    |> TitleSlug.unique_constraint(message: "Чат с таким названием уже существует. Попробуйте другое")
    |> cast_slug_or_id()
  end

  def cast_slug_or_id(chat) do
    id = get_change(chat, :id) || get_field(chat, :id)
    slug = get_change(chat, :slug) || get_field(chat, :slug)

    put_change(chat, :slug_or_id, slug || id)
  end
end
