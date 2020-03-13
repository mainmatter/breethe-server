defmodule Breethe.Sources.Google.Geocoding do
  defmodule Behaviour do
    @callback find_location(search_term :: String.t()) :: [coordinates :: number]
  end

  def find_location(search_term) do
    query =
      URI.encode_query(%{
        "address" => search_term,
        "key" => Application.get_env(:breethe, :google_maps_api_key)
      })

    query
    |> query_google_api()
    |> Jason.decode!()
    |> (& &1["results"]).()
    |> List.first()
    |> strip()
  end

  defp query_google_api(query) do
    url = "#{Application.get_env(:breethe, :google_maps_api_endpoint)}?#{query}"
    {:ok, response} = HTTPoison.get(url)
    response.body
  end

  defp strip(results) when is_nil(results), do: []
  defp strip(%{"geometry" => %{"location" => %{"lat" => lat, "lng" => lon}}}), do: [lat, lon]
end
