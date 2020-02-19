defmodule Breethe.Sources.EEA.CSVTest do
  use Breethe.DataCase

  alias Breethe.Sources.EEA.CSV

  @sample_valid_data """
  network_countrycode,network_localid,network_name,network_namespace,network_timezone,pollutant,samplingpoint_localid,samplingpoint_namespace,samplingpoint_x,samplingpoint_y,coordsys,station_code,station_localid,station_name,station_namespace,value_datetime_begin,value_datetime_end,value_datetime_inserted,value_datetime_updated,value_numeric,value_validity,value_verification,station_altitude,value_unit\r
  GB,NET-GB001A,National air network,GB.GB-ExEA.AQ,http://dd.eionet.europa.eu/vocabulary/aq/timezone/UTC+02,SO2,SPO-BG0071A_00001_100,GB.GB-ExEA.AQ,00.72,34.65975799999999,EPSG:4979,GB0071A,STA-GB0071A,London,GB.GB-ExEA.AQ,2019-11-10 23:00:00+01:00,2019-11-11 00:00:00+01:00,2019-11-11 01:29:21+01:00,+01:00,3,-1,1,27,ug/m3\r
  """

  @sample_invalid_data """
  network_countrycode,network_localid,network_name,network_namespace,network_timezone,pollutant,samplingpoint_localid,samplingpoint_namespace,samplingpoint_x,samplingpoint_y,coordsys,station_code,station_localid,station_name,station_namespace,value_datetime_begin,value_datetime_end,value_datetime_inserted,value_datetime_updated,value_numeric,value_validity,value_verification,station_altitude,value_unit\r
  GB,NET-GB001A,National air network,GB.GB-ExEA.AQ,http://dd.eionet.europa.eu/vocabulary/aq/timezone/UTC+02,SO2,SPO-BG0071A_00001_100,GB.GB-ExEA.AQ,00.72,34.65975799999999,EPSG:4979,GB0071A,STA-GB0071A,London,GB.GB-ExEA.AQ,2019-11-10 23:00:00+01:00,2019-11-11 00:00:00+01:00,2019-11-11 01:29:21+01:00,+01:00,,-1,1,27,ug/m3\r
  """

  describe "process_data(data): " do
    test "decodes and stores csv data in db" do
      CSV.process_data(@sample_valid_data)
      locations = Breethe.Data.all_locations()

      assert [
               %Breethe.Data.Location{
                 available_parameters: [],
                 city: "London",
                 coordinates: %Geo.Point{
                   coordinates: {34.65975799999999, 0.72},
                   properties: %{},
                   srid: 4326
                 },
                 country: "GB",
                 identifier: "GB0071A",
                 label: "London"
               }
             ] = locations
    end

    test "filters out data with no value" do
      CSV.process_data(@sample_invalid_data)
      locations = Breethe.Data.all_locations()

      assert [] = locations
    end
  end
end
