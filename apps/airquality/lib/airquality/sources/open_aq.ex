defmodule Airquality.Sources.OpenAQ do
  alias Airquality.Repo
  alias Airquality.Data.Location

  def get_locations(search_term) do
    [lat, lon] = find_location(search_term)

    get_locations(lat, lon)
  end

  def get_locations(lat, lon) do
    url = "https://api.openaq.org/v1/locations?coordinates=#{lat},#{lon}&nearest=10"
    {:ok, response} = HTTPoison.get(url)

    data = Poison.decode!(response.body)
    %{"results" => results} = data

    Enum.map(results, fn result ->
      %{
        "location" => identifier,
        "city" => city,
        "country" => country,
        "lastUpdated" => last_updated,
        "parameters" => available_parameters,
        "coordinates" => %{
          "latitude" => lat,
          "longitude" => lon
        }
      } = result

      {:ok, last_updated, _} = DateTime.from_iso8601(last_updated)

      params = %{
        identifier: identifier,
        city: city,
        country: country,
        last_updated: last_updated,
        available_parameters: available_parameters,
        coordinates: %Geo.Point{coordinates: {lat, lon}, srid: 4326}
      }

      changeset = Location.changeset(%Location{}, params)
      Repo.insert!(changeset)
    end)
  end

  def get_locations(location) do
  end

  defp find_location(search_term) do
    query =
      URI.encode_query(%{
        "address" => search_term,
        "key" => Application.get_env(:airquality, :google_maps_api_key)
      })

    url = "https://maps.googleapis.com/maps/api/geocode/json?#{query}"
    {:ok, response} = HTTPoison.get(url)

    data = Poison.decode!(response.body)
    %{"results" => [%{"geometry" => %{"location" => %{"lat" => lat, "lng" => lon}}}]} = data
    [lat, lon]
  end
end
