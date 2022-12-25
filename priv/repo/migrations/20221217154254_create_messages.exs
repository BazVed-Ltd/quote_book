defmodule QuoteBook.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :quote_id, :integer
      add :text, :string
      add :peer_id, references(:chats, on_delete: :nothing)
      add :from_id, references(:users, on_delete: :nothing)
      add :reply_message_id, references(:messages, on_delete: :nothing)
      add :fwd_from_message_id, references(:messages, on_delete: :nothing)

      add :date, :bigint

      timestamps()
    end

    create index(:messages, [:reply_message_id])
    create index(:messages, [:fwd_from_message_id])
    create index(:messages, [:from_id])
    create index(:messages, [:peer_id])
  end
end
