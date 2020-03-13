use Mix.Config

# Configure your database
config :breethe, Breethe.Repo,
  types: Breethe.PostgresTypes,
  username: "breethe",
  password: "breethe",
  database: "breethe_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :breethe, google_maps_api_key: "google_api_key"
config :breethe, google_api: Breethe.Sources.Google.GeocodingMock
