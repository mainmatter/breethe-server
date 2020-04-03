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
    |> Enum.map(fn [
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
                     _value_datetime_updated,
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
        # using inserted here as updated is an offset
        value_datetime_updated: value_datetime_inserted,
        value_numeric: value_numeric,
        value_validity: value_validity,
        value_verification: value_verification,
        station_altitude: station_altitude,
        value_unit: value_unit
      }
    end)
  end

  defp store_data(data) do
    data
    |> Enum.filter(fn datum -> datum.value_numeric != "" end)
    |> Enum.group_by(&Map.get(&1, :station_code))
    |> Enum.map(&store_station/1)
  end

  defp store_station(station_data) do
    {_, measurements} = station_data

    sorted_mesaurements =
      Enum.sort(measurements, &(&1.value_datetime_updated > &2.value_datetime_updated))

    [first_measurement | _] = sorted_mesaurements

    location =
      first_measurement
      |> extract_location()
      |> Data.create_location()

    measurements_params =
      sorted_mesaurements
      |> Enum.uniq_by(& &1.value_datetime_updated)
      |> Enum.map(&extract_measurement/1)
      |> Enum.map(fn measurement_params ->
        Map.put_new(measurement_params, :location_id, location.id)
      end)

    Data.import_measurements(location, measurements_params)
  end

  defp extract_location(datum) do
    %{
      identifier: datum.station_code,
      city: datum.station_name |> String.split(" - ") |> List.first(),
      country: datum.network_countrycode,
      last_updated: Timex.parse!(datum.value_datetime_updated, "{ISO:Extended:Z}"),
      available_parameters: [],
      coordinates: %Geo.Point{
        coordinates: {datum.samplingpoint_y, datum.samplingpoint_x},
        srid: 4326
      },
      label: datum.station_name
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
      "PM2.5" -> :pm25
      "SO2" -> :so2
      "NO2" -> :no2
      "O3" -> :o3
      "CO" -> :co
    end
  end
end
