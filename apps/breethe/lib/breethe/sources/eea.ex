defmodule Breethe.Sources.EEA do
  alias __MODULE__.CSV

  # @parameters ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]
  @parameters ["SO2", "NO2", "O3", "CO"]
  @country_codes [
    "BG",
    "CY",
    "CZ",
    "ES",
    "GR",
    "HR",
    "HU",
    "IE",
    "IS",
    "IT",
    "LT",
    "LU",
    "NO",
    "PT",
    "RS",
    "SE",
    "SK",
    "AD",
    "BA",
    "BE",
    "DE",
    "FI",
    "FR",
    "GB",
    "GI",
    "LV",
    "MT",
    "NL",
    "SI",
    "DK",
    "GE",
    "MK",
    "PL",
    "AT",
    "CH",
    "EE"
  ]

  def country_codes(), do: @country_codes

  def parameters(), do: @parameters

  def get_data() do
    for country <- country_codes(), param <- parameters() do
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
end
