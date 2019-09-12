defmodule Breethe.Sources.EEA.CSV do
  alias Breethe.Data

  alias NimbleCSV.RFC4180, as: NimbleCSV

  def process_data(data) do
    data
    |> parse_csv()
    |> store_data()
  end

  defp parse_csv(data) do
    data
    |> NimbleCSV.parse_string()
    |> Stream.map(fn [
                       network_countrycode,
                       network_localid,
                       network_name,
                       network_namespace,
                       network_timezone,
                       pollutant,
                       samplingpoint_localid,
                       samplingpoint_namespace,
                       samplingpoint_x,
                       samplingpoint_y,
                       coordsys,
                       station_code,
                       station_localid,
                       station_name,
                       station_namespace,
                       value_datetime_begin,
                       value_datetime_end,
                       value_datetime_inserted,
                       value_datetime_updated,
                       value_numeric,
                       value_validity,
                       value_verification,
                       station_altitude,
                       value_unit
                     ] ->
      %{
        network_countrycode: network_countrycode,
        network_localid: network_localid,
        network_name: :unicode.characters_to_binary(network_name, :latin1, :utf8),
        network_namespace: network_namespace,
        network_timezone: network_timezone,
        pollutant: pollutant,
        samplingpoint_localid: samplingpoint_localid,
        samplingpoint_namespace: samplingpoint_namespace,
        samplingpoint_x: samplingpoint_x,
        samplingpoint_y: samplingpoint_y,
        coordsys: coordsys,
        station_code: station_code,
        station_localid: station_localid,
        station_name: :unicode.characters_to_binary(station_name, :latin1, :utf8),
        station_namespace: station_namespace,
        value_datetime_begin: value_datetime_begin,
        value_datetime_end: value_datetime_end,
        value_datetime_inserted: value_datetime_inserted,
        value_datetime_updated: value_datetime_inserted,
        value_numeric: value_numeric,
        value_validity: value_validity,
        value_verification: value_verification,
        station_altitude: station_altitude,
        value_unit: value_unit
      }
    end)
  end

  defp store_data(stream) do
    stream
    |> Stream.map(&store_datum/1)
    |> Stream.run()
  end

  defp store_datum(datum) do
    location =
      datum
      |> extract_location()
      |> Data.create_location()

    _measurement =
      datum
      |> extract_measurement()
      |> Map.put_new(:location_id, location.id)
      |> Data.create_measurement()
  end

  defp extract_location(datum) do
    %{
      identifier: datum.station_code,
      city: "S",
      country: datum.network_countrycode,
      last_updated: Timex.parse!(datum.value_datetime_updated, "{ISO:Extended:Z}"),
      available_parameters: [],
      coordinates: %Geo.Point{
        coordinates: {datum.samplingpoint_y, datum.samplingpoint_x},
        srid: 4326
      }
    }
  end

  defp extract_measurement(datum) do
    %{
      parameter: determine_pollutant(datum.pollutant),
      measured_at: Timex.parse!(datum.value_datetime_updated, "{ISO:Extended:Z}"),
      value: datum.value_numeric
    }
  end

  defp determine_pollutant(pollutant) do
    case pollutant do
      "PM10" -> :pm10
      _ -> :bc
    end
  end
end
