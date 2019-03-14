use Mix.Config

config :breethe, Breethe.Repo,
  types: Breethe.PostgresTypes,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true
