defmodule QuoteBook.Repo.Migrations.AddPublishedId do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      add :published_id, :integer
    end
  end
end
