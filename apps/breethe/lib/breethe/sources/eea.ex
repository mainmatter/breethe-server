defmodule Breethe.Sources.EEA do
  alias __MODULE__.CSV

  @countries [
    %{country: "AD", params: ["PM10", "SO2", "NO2", "O3", "CO"]},
    %{country: "AT", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "BA", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "BE", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "BG", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "CH", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "CY", params: ["SO2", "NO2", "O3", "CO"]},
    %{country: "CZ", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "DE", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "DK", params: ["SO2", "NO2", "O3", "CO"]},
    %{country: "EE", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "ES", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "FI", params: ["PM10", "PM2.5", "SO2", "NO2", "O3"]},
    %{country: "FR", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "GB", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "GE", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "GI", params: ["PM10", "SO2", "NO2", "O3", "CO"]},
    %{country: "GR", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "HR", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "HU", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "IE", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "IS", params: ["PM10", "PM2.5", "SO2", "NO2"]},
    %{country: "IT", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "LT", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "LU", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "LV", params: ["SO2", "NO2", "O3", "CO"]},
    %{country: "MK", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "MT", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "NL", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "NO", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "PL", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "PT", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "RS", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]},
    %{country: "SE", params: ["PM10", "PM2.5", "SO2", "NO2", "O3"]},
    %{country: "SI", params: ["PM10", "SO2", "NO2", "O3", "CO"]},
    %{country: "SK", params: ["PM10", "PM2.5", "SO2", "NO2", "O3", "CO"]}
  ]

  def countries(), do: @countries

  def get_data() do
    for %{country: country, params: params} <- countries(), param <- params do
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
