defmodule QuoteBook.Repo.Migrations.AddSyncedAtInChats do
  use Ecto.Migration

  def change do
    alter table(:chats) do
      add :synced_at, :naive_datetime
    end
  end
end
