defmodule QuoteBook.Repo.Migrations.CreateAttachments do
  use Ecto.Migration

  def change do
    create table(:attachments) do
      add :message_id, references(:messages, on_delete: :nothing)
      add :path, :string
      add :type, :string

      timestamps()
    end
  end
end
