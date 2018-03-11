use Mix.Config

config :airquality, ecto_repos: [Airquality.Repo]
config :airquality, google_maps_api_key: "AIzaSyBBlWdXl4PykS60hfR3_-6zCK2PX0GLCtQ"

import_config "#{Mix.env()}.exs"
