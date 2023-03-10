import Config

# Configure your database
config :quote_book, QuoteBook.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "quote_book_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

dev_secret_key = "wgklF6yY2p6YzyFfMu7KiTVBwBuiJ+f7Ok1jpBz2HNkbT/OAVq6bSQqn+CkQN9ea"

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with esbuild to bundle .js and .css sources.
config :quote_book, QuoteBookWeb.Endpoint,
  # Binding to loopback ipv4 address prevents access from other machines.
  # Change to `ip: {0, 0, 0, 0}` to allow access from other machines.
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: dev_secret_key,
  watchers: [
    # Start the esbuild watcher by calling Esbuild.install_and_run(:default, args)
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :quote_book, QuoteBookWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/quote_book_web/(live|views)/.*(ex)$",
      ~r"lib/quote_book_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :quote_book, QuoteBook.Guardian,
  secret_key: dev_secret_key

config :quote_book,
  attachments_directory: "priv/static/attachments",
  renders_directory: "priv/renders",
  back_url: "http://localhost:4000",
  screenshoter_url: "http://localhost:4001",
  screenshoter_key: dev_secret_key

import_config "#{Mix.env()}.secret.exs"
