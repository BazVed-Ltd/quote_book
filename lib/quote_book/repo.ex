defmodule QuoteBook.Repo do
  use Ecto.Repo,
    otp_app: :quote_book,
    adapter: Ecto.Adapters.Postgres
end
