defmodule QuoteBook.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :quote_book,
    adapter: Ecto.Adapters.Postgres
end
