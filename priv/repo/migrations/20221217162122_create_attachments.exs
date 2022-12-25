defmodule QuoteBook.Repo.Migrations.CreateAttachments do
  use Ecto.Migration

  def change do
    create table(:attachments) do
      add :message_id, references(:messages, on_delete: :delete_all)
      add :path, :string
      add :type, :string
      add :ext, :string

      timestamps()
    end
  end
end
