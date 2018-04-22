defmodule Airquality.Sources.OpenAQ.Measurements do
  alias Airquality.Data.{Measurement, Location}
  alias Airquality.Repo

  def get_latest(location_id) do
    location = get_location(location_id)

    result = query_open_aq(location.identifier)
    measurements = result["measurements"]

    Enum.each(measurements, fn measurement ->
      params =
        measurement
        |> parse_measurement()
        |> Map.put_new(:location_id, location.id)

      create_measurement(params)
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

  defp query_open_aq(identifier) do
    url =
      "#{Application.get_env(:airquality, :open_aq_api_endpoint)}/latest?location=#{identifier}"

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

  defp create_measurement(params) do
    %Measurement{}
    |> Measurement.changeset(params)
    |> Repo.insert!()
  end

  defp get_location(location_id) do
    Repo.get(Location, location_id)
  end
end
