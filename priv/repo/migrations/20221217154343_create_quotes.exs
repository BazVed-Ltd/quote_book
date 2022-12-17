defmodule QuoteBook.Repo.Migrations.CreateQuotes do
  use Ecto.Migration

  def change do
    create table(:quotes) do
      add :message_id, references(:messages, on_delete: :nothing)

      timestamps()
    end

    create index(:quotes, [:message_id])
  end
end
