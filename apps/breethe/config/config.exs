use Mix.Config

config :breethe, ecto_repos: [Breethe.Repo]
config :breethe, google_maps_api_key: System.get_env("GOOGLE_API_KEY")
config :breethe, google_maps_api_endpoint: "https://maps.googleapis.com/maps/api/geocode/json"
config :breethe, open_aq_api_endpoint: "https://api.openaq.org/v1"
config :breethe, eea_endpoint: "https://discomap.eea.europa.eu/map/fme/latest"
config :breethe, source: Breethe.Sources

config :logger, backends: [:console]

import_config "#{Mix.env()}.exs"
