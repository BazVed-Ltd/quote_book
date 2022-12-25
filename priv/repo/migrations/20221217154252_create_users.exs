defmodule QuoteBook.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :current_photo, :string

      timestamps()
    end
  end
end
