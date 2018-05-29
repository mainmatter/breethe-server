defmodule Breethe.Sources.OpenAQ.Locations do
  alias Breethe.Data

  def get_locations(lat, lon) do
    results = query_open_aq(lat, lon)

    Enum.map(results, fn result ->
      params = parse_location(result)

      params.last_updated
      |> DateTime.diff(DateTime.utc_now(), :milliseconds)
      |> recent?()
      |> case do
        true -> Data.create_location(params)
        false -> []
      end
    end)
    |> List.flatten()
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
      "#{Application.get_env(:breethe, :open_aq_api_endpoint)}/locations?coordinates=#{lat},#{lon}&nearest=10"

    {:ok, response} = HTTPoison.get(url)
    %{"results" => results} = Poison.decode!(response.body)
    results
  end

  defp recent?(diff), do: :timer.hours(24 * 7) * -1 < diff
end
