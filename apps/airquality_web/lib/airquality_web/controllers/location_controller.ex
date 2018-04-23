defmodule AirqualityWeb.LocationController do
  use AirqualityWeb, :controller
  alias Airquality.Sources.OpenAQ
  require IEx

  def index(conn, %{"filter" => %{"search" => search_term}}) do
    locations = OpenAQ.get_locations(search_term)

    render(conn, "index.json-api", data: locations)
  end
end
