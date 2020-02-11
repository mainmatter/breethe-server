defmodule Breethe.Sources.EEA do
  alias __MODULE__.{CSV, Download}

  def country_codes(),
    do: [
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

  # @parameters ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]
  def parameters(), do: ["SO2", "NO2", "O3", "CO"]

  def get_data() do
    for country <- country_codes(), param <- parameters() do
      country
      |> Download.get_latest(param)
      |> case do
        {:ok, response} -> CSV.process_data(response.body)
        {:error, reason} -> reason
      end
    end
  end
end
