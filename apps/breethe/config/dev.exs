use Mix.Config

# Configure your database
config :breethe, Breethe.Repo,
  types: Breethe.PostgresTypes,
  username: "breethe",
  password: "breethe",
  database: "breethe_dev",
  hostname: "localhost",
  pool_size: 10,
  owenership_timeout: 99_999_999
