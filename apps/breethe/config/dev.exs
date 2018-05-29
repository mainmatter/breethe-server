use Mix.Config

# Configure your database
config :breethe, Breethe.Repo,
  adapter: Ecto.Adapters.Postgres,
  types: Breethe.PostgresTypes,
  username: "breethe",
  password: "breethe",
  database: "breethe_dev",
  hostname: "localhost",
  pool_size: 10
