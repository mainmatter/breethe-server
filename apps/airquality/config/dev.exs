use Mix.Config

# Configure your database
config :airquality, Airquality.Repo,
  adapter: Ecto.Adapters.Postgres,
  types: Airquality.PostgresTypes,
  username: "airquality",
  password: "airquality",
  database: "airquality_dev",
  hostname: "localhost",
  pool_size: 10
