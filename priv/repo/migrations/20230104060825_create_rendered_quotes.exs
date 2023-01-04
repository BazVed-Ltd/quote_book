defmodule QuoteBook.Repo.Migrations.CreateRenderedQuotes do
  use Ecto.Migration

  def change do
    create table(:rendered_quotes) do
      add :local_path, :string
      add :vk_path, :string

      timestamps()
    end
  end
end
