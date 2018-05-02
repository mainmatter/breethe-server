defmodule Airquality.Sources.OpenAQ.Locations do
  alias Airquality.Repo
  alias Airquality.Data.Location

  def get_locations(lat, lon) do
    results = query_open_aq(lat, lon)

    Enum.map(results, fn result ->
      params = parse_location(result)

      create_location(params)
    end)
  end

  defp parse_location(location) do
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
    } = location

    %{
      identifier: identifier,
      city: city,
      country: country,
      last_updated: Timex.parse!(last_updated, "{ISO:Extended:Z}"),
      available_parameters: available_parameters,
      coordinates: %Geo.Point{coordinates: {lat, lon}, srid: 4326}
    }
  end

  defp query_open_aq(lat, lon) do
    url =
      "#{Application.get_env(:airquality, :open_aq_api_endpoint)}/locations?coordinates=#{lat},#{
        lon
      }&nearest=100"

    {:ok, response} = HTTPoison.get(url)
    %{"results" => results} = Poison.decode!(response.body)
    results
  end

  defp get_location(params) do
    Location
    |> Repo.get_by(Map.take(params, [:city, :coordinates, :identifier, :country]))
    |> Repo.preload(:measurements)
  end

  defp create_location(params) do
    case get_location(params) do
      nil -> %Location{}
      location -> location
    end
    |> Location.changeset(params)
    |> Repo.insert_or_update!()
  end
end
