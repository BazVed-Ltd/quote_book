defmodule QuoteBook.Book.Chat do
  @moduledoc """
  Чат, в котором сохраняются цитаты.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias QuoteBook.Book.Chat.TitleSlug

  @type t :: %__MODULE__{
          id: non_neg_integer() | nil,
          title: String.t() | nil,
          covers: [String.t()] | nil,
          slug: String.t() | nil,
        }

  schema "chats" do
    field :title, :string
    field :covers, {:array, :string}, default: []

    field :slug, TitleSlug.Type

    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:id, :title, :covers])
    |> validate_required([:id])
    |> unique_constraint(:title,
      message: "Чат с таким названием уже существует. Попробуйте другое"
    )
    |> validate_length(:title,
      min: 1,
      max: 24,
      message: "Название чата не должно превышать 24 символа"
    )
    |> validate_format(:title, ~r/\p{L}/u, message: "Название должно содержать хотя бы одну букву")
    |> TitleSlug.maybe_generate_slug()
    |> TitleSlug.unique_constraint(
      message: "Чат с таким названием уже существует. Попробуйте другое"
    )
  end

  @spec slug_or_id(t()) :: String.t() | non_neg_integer()
  def slug_or_id(chat) do
    chat.slug || chat.id
  end
end
