defmodule QuoteBook.Repo.Migrations.AddNameToUsers do
  use Ecto.Migration

  def up do
    alter table(:users) do
      add :name, :string
    end

    execute """
    UPDATE users SET name = CONCAT(first_name, ' ', last_name);
    """

    alter table(:users) do
      remove :first_name
      remove :last_name
    end
  end

  def down do
    alter table(:users) do
      add :first_name, :string
      add :last_name, :string
    end

    execute """
    UPDATE users SET first_name = SPLIT_PART(name, ',', 1), last_name = SPLIT_PART(name, ',', 2);
    """

    alter table(:users) do
      remove :name
    end
  end
end
