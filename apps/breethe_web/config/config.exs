# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :breethe_web,
  namespace: BreetheWeb,
  ecto_repos: [Breethe.Repo]

config :breethe_web, source: Breethe

# Configures the endpoint
config :breethe_web, BreetheWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "VLa9yYVmVQQl2sFRfl1+zV8mgnytlYSoV3qAK4lM1M3bgeUlx/kkEkeNd+mnq/9L",
  render_errors: [view: BreetheWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: BreetheWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :breethe_web, :generators, context_app: :breethe

config :phoenix, :format_encoders, "json-api": Poison

config :mime, :types, %{
  "application/vnd.api+json" => ["json-api"]
}

config :ja_serializer, key_format: {:custom, JsonApiKeys, :camelize, :underscore}
config :ja_serializer, type_format: {:custom, JsonApiKeys, :camelize}

config :cors_plug, origin: ["https://breethe.app", "https://dev.breethe"]

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: Mix.env(),
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  included_environments: [:prod],
  json_library: Poison

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
