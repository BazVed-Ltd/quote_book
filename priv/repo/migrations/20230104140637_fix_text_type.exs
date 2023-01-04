defmodule QuoteBook.Repo.Migrations.FixTextType do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      modify :text, :text
    end
  end
end
