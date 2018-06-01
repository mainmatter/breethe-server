use Mix.Config

# Configure your database
config :breethe, Breethe.Repo,
  adapter: Ecto.Adapters.Postgres,
  types: Breethe.PostgresTypes,
  username: "breethe",
  password: "breethe",
  database: "breethe_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :breethe, source: Breethe.Sources.OpenAQMock
config :breethe, google_maps_api_key: "google_api_key"
