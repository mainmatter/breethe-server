defmodule Airquality.Sources.OpenAQ do
  alias Airquality.Repo
  alias Airquality.Data.Location

  def get_locations(search_term) do
    [lat, lon] = find_location(search_term)

    get_locations(lat, lon)
  end

  def get_locations(lat, lon) do
    url = "#{Application.get_env(:airquality, :open_aq_api_endpoint)}/locations?coordinates=#{lat},#{lon}&nearest=100"
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

      params = %{
        identifier: identifier,
        city: city,
        country: country,
        last_updated: Timex.parse!(last_updated, "{ISO:Extended:Z}"),
        available_parameters: available_parameters,
        coordinates: %Geo.Point{coordinates: {lat, lon}, srid: 4326}
      }

      changeset = Location.changeset(%Location{}, params)
      Repo.insert!(changeset)
    end)
  end

  defp find_location(search_term) do
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
