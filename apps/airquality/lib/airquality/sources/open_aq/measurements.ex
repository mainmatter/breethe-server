defmodule Airquality.Sources.OpenAQ.Measurements do
  alias Airquality.Data

  def get_latest(lat, lon) do
    result = query_open_aq(lat, lon)
    measurements = result["measurements"]

    location = Data.get_location(lat, lon)

    Enum.each(measurements, fn measurement ->
      params =
        measurement
        |> parse_measurement()
        |> Map.put_new(:location_id, location.id)
        |> Data.add_coordinates(lat, lon)

      Data.create_measurement(params)
    end)
  end

  def parse_measurement(measurement) do
    %{
      "parameter" => parameter,
      "lastUpdated" => measured_at,
      "value" => value,
      "unit" => unit
    } = measurement

    %{
      parameter: parameter,
      measured_at: Timex.parse!(measured_at, "{ISO:Extended:Z}"),
      value: value,
      unit: convert_unit(unit)
    }
  end

  defp query_open_aq(lat, lon) do
    url =
      "#{Application.get_env(:airquality, :open_aq_api_endpoint)}/latest?coordinates=#{lat},#{lon}"

    {:ok, response} = HTTPoison.get(url)
    %{"results" => [result]} = Poison.decode!(response.body)
    result
  end

  defp convert_unit(unit) do
    case unit do
      "µg/m³" -> :micro_grams_m3
      "mg/m³" -> :milli_grams_m3
    end
  end
end
