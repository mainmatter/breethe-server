use Mix.Config

# Configure your database
config :airquality, Airquality.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "airquality_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
