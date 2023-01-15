defmodule QuoteBook.Repo.Migrations.AddChatsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :chat_ids, {:array, :bigint}
    end
  end
end
