defmodule QuoteBook.Book.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :current_photo, :string
    field :name, :string

    field :first_name, :string, virtual: true
    field :last_name, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :name, :first_name, :last_name, :current_photo])
    |> validate_required([:id, :current_photo])
    |> cast_by_type()
    |> cast_name_from_first_and_last()
  end

  defp cast_name_from_first_and_last(user) do
    first_name = get_change(user, :first_name)
    last_name = get_change(user, :last_name)

    if is_nil(first_name) or is_nil(last_name) do
      user
    else
      put_change(user, :name, "#{first_name} #{last_name}")
    end
    |> validate_required([:name])
  end

  defp cast_by_type(user) do
    id = get_change(user, :id)

    if id < 0 do
      put_change(user, :id, -id + 2_000_000_000)
    else
      user
    end
  end
end
