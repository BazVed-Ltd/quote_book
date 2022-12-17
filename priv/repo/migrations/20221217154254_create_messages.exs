defmodule QuoteBook.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :text, :string
      add :peer_id, :integer
      add :from_id, :integer
      add :reply_message_id, references(:messages, on_delete: :nothing)

      add :datetime, :integer

      timestamps()
    end

    create index(:messages, [:reply_message_id])
  end
end
