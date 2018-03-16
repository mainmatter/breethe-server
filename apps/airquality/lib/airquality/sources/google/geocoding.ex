defmodule Airquality.Sources.Google.Geocoding do
  def find_location(search_term) do
    query =
      URI.encode_query(%{
        "address" => search_term,
        "key" => Application.get_env(:airquality, :google_maps_api_key)
      })

    url = "#{Application.get_env(:airquality, :google_maps_api_endpoint)}?#{query}"
    {:ok, response} = HTTPoison.get(url)

    data = Poison.decode!(response.body)
    %{"results" => [%{"geometry" => %{"location" => %{"lat" => lat, "lng" => lon}}}]} = data
    [lat, lon]
  end
end
