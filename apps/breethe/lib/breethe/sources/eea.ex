defmodule Breethe.Sources.EEA do
  alias __MODULE__.CSV

  @supported_params ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]
  @file_regex ~r/.*(?<country>\w{2})_(?<param>[\w\.]{2,5})\.csv$/

  def available_countries_and_params() do
    {:ok, response} = download_countries_and_params()

    response.body
    |> String.split("\n")
    |> Enum.map(&String.trim(&1))
    |> Enum.map(&Regex.named_captures(@file_regex, &1))
    |> Enum.reject(&is_nil/1)
    |> Enum.filter(fn %{"param" => param} -> Enum.member?(@supported_params, param) end)
    |> Enum.group_by(&Map.get(&1, "country"))
    |> Enum.map(fn {country, data} ->
      %{country: country, params: Enum.map(data, &Map.get(&1, "param"))}
    end)
  end

  def get_data() do
    for %{country: country, params: params} <- available_countries_and_params(),
        param <- params do
      country
      |> download_latest(param)
      |> case do
        {:ok, response} -> CSV.process_data(response.body)
        {:error, reason} -> reason
      end
    end
  end

  defp download_latest(country, param) do
    url = "#{Application.get_env(:breethe, :eea_endpoint)}/#{country}_#{param}.csv"

    HTTPoison.get(url)
  end

  defp download_countries_and_params do
    url = "#{Application.get_env(:breethe, :eea_endpoint)}/files.txt"

    HTTPoison.get(url)
  end
end
