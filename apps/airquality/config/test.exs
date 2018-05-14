use Mix.Config

# Configure your database
config :airquality, Airquality.Repo,
  adapter: Ecto.Adapters.Postgres,
  types: Airquality.PostgresTypes,
  username: "airquality",
  password: "airquality",
  database: "airquality_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :airquality, source: Airquality.Mock
