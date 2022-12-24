defmodule QuoteBook.Repo.Migrations.ChangeIdsInMessageToBigInt do
  use Ecto.Migration

  def change do
    alter table(:messages) do
      modify :from_id, :bigint
      modify :peer_id, :bigint
    end
  end
end
