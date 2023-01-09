import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :quote_book, QuoteBook.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "quote_book_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :quote_book, QuoteBookWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "D7gfp0f5T/YwmVCgOnBMLlzs0emxX0tm6WpHwzmmyIvIrNdFoPuPvTBhHqmQWgqa",
  server: false

config :vk_bot,
  in_test: true

# In test we don't send emails.
config :quote_book, QuoteBook.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
