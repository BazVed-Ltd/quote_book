defmodule QuoteBook.Repo.Migrations.AddCoversToChats do
  use Ecto.Migration

  def change do
    alter table(:chats) do
      add :covers, {:array, :string}
    end
  end
end
