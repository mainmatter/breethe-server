defmodule Airquality.Sources.OpenAQ.InMemory do
  import Airquality.Factory

  def get_locations(search_term) when is_binary(search_term) do
    lat = 10
    lon = 20

    get_locations(lat, lon)
  end

  def get_locations(lat, lon) when is_number(lat) and is_number(lon) do
    _locations = build_list(1, :location)
  end
end
