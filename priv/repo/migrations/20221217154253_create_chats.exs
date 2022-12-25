defmodule QuoteBook.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :title, :string
      add :covers, {:array, :string}

      timestamps()
    end
  end
end
