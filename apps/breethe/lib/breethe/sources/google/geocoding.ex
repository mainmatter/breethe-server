defmodule Breethe.Sources.Google.Geocoding do
  require IEx

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

  def find_location(lat, lon) do
    query =
      URI.encode_query(%{
        "latlng" => "#{lat},#{lon}",
        "key" => Application.get_env(:breethe, :google_maps_api_key)
      })

    query
    |> query_google_api()
    |> Jason.decode!()
    |> strip()
  end

  def find_location_country_code(search_term) do
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
    |> (& &1["address_components"]).()
    |> find_country_code()
  end

  # def find_location_city(lat, lon) do
  #   query =
  #     URI.encode_query(%{
  #       "latlng" => "#{lat},#{lon}",
  #       "result_type" => "locality",
  #       "key" => Application.get_env(:breethe, :google_maps_api_key)
  #     })

  #   query
  #   |> query_google_api()
  #   |> Jason.decode!()
  #   |> strip()
  # end

  defp query_google_api(query) do
    url = "#{Application.get_env(:breethe, :google_maps_api_endpoint)}?#{query}"
    {:ok, response} = HTTPoison.get(url)
    response.body
  end

  defp strip(results) when is_nil(results), do: []
  defp strip(%{"geometry" => %{"location" => %{"lat" => lat, "lng" => lon}}}), do: [lat, lon]

  defp strip(results) do
    all = fn :get, data, next -> Enum.map(data, next) end

    results
    |> get_in(["results", all, "formatted_address"])
    |> List.first()
  end

  defp find_country_code(results) do
    results
    |> Enum.find(fn results ->
      match?(%{"short_name" => _, "types" => ["country", _]}, results)
    end)
    |> Map.get("short_name")
  end
end
