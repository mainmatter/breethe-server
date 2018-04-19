defmodule Airquality.Sources.OpenAQ.Measurements do
  alias Airquality.Repo
  alias Airquality.Data.{Measurement, Location}

  def get_latest(lat, lon) do
    url =
      "#{Application.get_env(:airquality, :open_aq_api_endpoint)}/latest?coordinates=#{lat},#{lon}"

    {:ok, response} = HTTPoison.get(url)
    data = Poison.decode!(response.body)

    %{"results" => results} = data

    Enum.each(results, fn result ->
      measurements = result["measurements"]

      Enum.each(measurements, fn measurement ->
        params = parse_measurement(measurement, lat, lon)
        changeset = Measurement.changeset(%Measurement{}, params)
        Repo.insert!(changeset)
      end)
    end)
  end

  def parse_measurement(measurement, lat, lon) do
    location = Repo.get_by(Location, coordinates: %Geo.Point{coordinates: {lat, lon}, srid: 4326})

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
      unit: convert_unit(unit),
      coordinates: %Geo.Point{coordinates: {lat, lon}, srid: 4326},
      location_id: location.id
    }
  end

  def convert_unit(unit) do
    case unit do
      "µg/m³" -> :micro_grams_m3
      "mg/m³" -> :milli_grams_m3
    end
  end
end
