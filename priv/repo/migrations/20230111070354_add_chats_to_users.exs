defmodule QuoteBook.Repo.Migrations.AddChatsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :chats, {:array, :bigint}
    end
  end
end
