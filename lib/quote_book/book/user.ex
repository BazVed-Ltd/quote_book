defmodule QuoteBook.Book.User do
  @moduledoc """
  Пользователь, сохранивший или отправивший сохранённое сообщение в чате.

  Каждые шесть часов `QuoteBook.Scheduler` запускает
  `QuoteBookBot.Utils.UserLoader.update_exists_users/0`, который обновляет имя
  и фотографию каждого пользователя.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: non_neg_integer() | nil,
          current_photo: String.t() | nil,
          name: String.t() | nil,
          chats: [non_neg_integer()]
        }

  schema "users" do
    field :current_photo, :string
    field :name, :string

    field :first_name, :string, virtual: true
    field :last_name, :string, virtual: true

    field :chats, {:array, :integer}

    timestamps()
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:id, :name, :first_name, :last_name, :current_photo, :chats])
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
