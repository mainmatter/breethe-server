use Mix.Config

config :breethe, ecto_repos: [Breethe.Repo]
config :breethe, google_maps_api_key: System.get_env("GOOGLE_API_KEY")
config :breethe, google_maps_api_endpoint: "https://maps.googleapis.com/maps/api/geocode/json"
config :breethe, eea_endpoint: "https://discomap.eea.europa.eu/map/fme/latest"

config :logger, backends: [:console]

import_config "#{Mix.env()}.exs"
