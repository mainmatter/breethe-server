defmodule Airquality.Sources.HTTPClient do
  @behaviour Airquality.Sources.Behaviour

  alias Airquality.Sources.{Google, OpenAQ}

  def get_locations(search_term) do
    [lat, lon] = Google.Geocoding.find_location(search_term)

    get_locations(lat, lon)
  end

  def get_locations(lat, lon) do
    OpenAQ.Locations.get_locations(lat, lon)
  end

  def get_latest_measurements(location_id) do
    OpenAQ.Measurements.get_latest(location_id)
  end
end
