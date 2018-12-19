defmodule Breethe.Sources.OpenAQ.Measurements do
  alias Breethe.Data

  def get_latest(location_id) do
    location = Data.get_location(location_id)

    measurements =
      case query_open_aq(location.identifier) do
        %{"results" => []} -> []
        %{"results" => [result]} -> result["measurements"]
      end

    Enum.map(measurements, fn measurement ->
      params =
        measurement
        |> parse_measurement()
        |> Map.put_new(:location_id, location.id)

      Data.create_measurement(params)
    end)
  end

  defp parse_measurement(measurement) do
    %{
      "parameter" => parameter,
      "lastUpdated" => measured_at,
      "value" => value,
      "unit" => unit
    } = measurement

    {value, unit} = convert_measurement(parameter, value, unit)

    %{
      parameter: parameter,
      measured_at: Timex.parse!(measured_at, "{ISO:Extended:Z}"),
      value: value,
      unit: unit
    }
  end

  defp query_open_aq(identifier) do
    identifier = URI.encode(identifier)

    url = "#{Application.get_env(:breethe, :open_aq_api_endpoint)}/latest?location=#{identifier}"

    {:ok, response} = HTTPoison.get(url)
    Jason.decode!(response.body)
  end

  defp convert_measurement(parameter, value, unit) do
    case unit do
      "µg/m³" -> {value, :micro_grams_m3}
      "ppm" -> {convert_to_micro_grams_m3(parameter, value), :micro_grams_m3}
    end
  end

  defp convert_to_micro_grams_m3(parameter, ppm_value) do
    molar_mass =
      case parameter do
        "so2" -> 64.0638
        "no2" -> 46.0055
        "o3" -> 47.9982
        "co" -> 28.0101
      end

    # rough conversion which assumes a temp of 0C and 1atm (101.325 kPa) of pressure.
    # precise formula: ppm * (molar_mass / 22.414) * (273.15 / T) * (P / 101.325)
    # 22.414 is the molar volume of the mixture, 273.15K = OC, T is temperature of measurement in K, P is pressure of measurement in kPa

    ppm_value * (molar_mass / 22.414) * 1000
  end
end
