defmodule AirqualityWeb.Router do
  use AirqualityWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/api", AirqualityWeb do
    pipe_through(:api)
  end
end
