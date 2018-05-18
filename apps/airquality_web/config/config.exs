# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :airquality_web,
  namespace: AirqualityWeb,
  ecto_repos: [Airquality.Repo]

config :airquality_web, source: Airquality

# Configures the endpoint
config :airquality_web, AirqualityWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VLa9yYVmVQQl2sFRfl1+zV8mgnytlYSoV3qAK4lM1M3bgeUlx/kkEkeNd+mnq/9L",
  render_errors: [view: AirqualityWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: AirqualityWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :airquality_web, :generators, context_app: :airquality

config :phoenix, :format_encoders, "json-api": Poison

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: Mix.env(),
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  included_environments: [:prod]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
