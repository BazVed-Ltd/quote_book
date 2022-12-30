defmodule QuoteBook.Repo.Migrations.AddSlugToChats do
  use Ecto.Migration

  def change do
    alter table(:chats) do
      add :slug, :string
    end

    create unique_index(:chats, [:title])
    create unique_index(:chats, [:slug])
  end
end
