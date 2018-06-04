defmodule Breethe.Sources.Google.Geocoding do
  def find_location(search_term) do
    query =
      URI.encode_query(%{
        "address" => search_term,
        "key" => Application.get_env(:breethe, :google_maps_api_key)
      })

    query
    |> query_google_api()
    |> Poison.decode!()
    |> (& &1["results"]).()
    |> List.first()
    |> strip()
  end

  def find_location(lat, lon) do
    query =
      URI.encode_query(%{
        "latlng" => "#{lat},#{lon}",
        "key" => Application.get_env(:breethe, :google_maps_api_key)
      })

    query
    |> query_google_api()
    |> Poison.decode!()
    |> strip()
  end

  defp query_google_api(query) do
    url = "#{Application.get_env(:breethe, :google_maps_api_endpoint)}?#{query}"
    {:ok, response} = HTTPoison.get(url)
    response.body
  end

  defp strip(%{"geometry" => %{"location" => %{"lat" => lat, "lng" => lon}}}), do: [lat, lon]

  defp strip(results) do
    all = fn :get, data, next -> Enum.map(data, next) end

    results
    |> get_in(["results", all, "formatted_address"])
    |> List.first()
  end
end
