defmodule QuoteBook.Book.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :current_photo, :string
    field :first_name, :string
    field :last_name, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :first_name, :last_name, :current_photo])
    |> validate_required([:id, :first_name, :last_name, :current_photo])
  end
end
