use Mix.Config

config :airquality, ecto_repos: [Airquality.Repo]
config :airquality, google_maps_api_key: "AIzaSyBBlWdXl4PykS60hfR3_-6zCK2PX0GLCtQ"
config :airquality, google_maps_api_endpoint: "https://maps.googleapis.com/maps/api/geocode/json"
config :airquality, open_aq_api_endpoint: "https://api.openaq.org/v1"
config :airquality, source: Airquality.Sources.OpenAQ

config :logger, backends: [:console]

import_config "#{Mix.env()}.exs"
