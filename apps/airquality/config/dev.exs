use Mix.Config

# Configure your database
config :airquality, Airquality.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "airquality",
  password: "airquality",
  database: "airquality_dev",
  hostname: "localhost",
  pool_size: 10
