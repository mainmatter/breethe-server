defmodule Airquality.Sources.OpenAQ do
  alias Airquality.Sources.Google
  alias Airquality.Sources.OpenAQ.Locations

  def get_locations(search_term) do
    [lat, lon] = Google.Geocoding.find_location(search_term)

    get_locations(lat, lon)
  end

  def get_locations(lat, lon) do
    Locations.get_locations(lat, lon)
  end
end
