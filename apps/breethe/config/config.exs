use Mix.Config

config :breethe, ecto_repos: [Breethe.Repo]
config :breethe, google_maps_api_key: "AIzaSyBBlWdXl4PykS60hfR3_-6zCK2PX0GLCtQ"
config :breethe, google_maps_api_endpoint: "https://maps.googleapis.com/maps/api/geocode/json"
config :breethe, open_aq_api_endpoint: "https://api.openaq.org/v1"
config :breethe, source: Breethe.Sources.OpenAQ

config :logger, backends: [:console]

import_config "#{Mix.env()}.exs"
