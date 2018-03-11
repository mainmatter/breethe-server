use Mix.Config

config :airquality, ecto_repos: [Airquality.Repo]

import_config "#{Mix.env()}.exs"
