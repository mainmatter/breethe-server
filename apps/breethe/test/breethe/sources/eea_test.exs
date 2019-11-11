defmodule Breethe.Sources.EEATest do
  use Breethe.DataCase

  import Mox
  import Breethe.Factory

  alias Breethe.Sources.EEA

  require IEx

  @sample_payload "network_countrycode,network_localid,network_name,network_namespace,network_timezone,pollutant,samplingpoint_localid,samplingpoint_namespace,samplingpoint_x,samplingpoint_y,coordsys,station_code,station_localid,station_name,station_namespace,value_datetime_begin,value_datetime_end,value_datetime_inserted,value_datetime_updated,value_numeric,value_validity,value_verification,station_altitude,value_unit\r\nBG,NET-BG001A,National air network,BG.BG-ExEA.AQ,http://dd.eionet.europa.eu/vocabulary/aq/timezone/UTC+02,SO2,SPO-BG0071A_00001_100,BG.BG-ExEA.AQ,27.720956,42.65975799999999,EPSG:4979,BG0071A,STA-BG0071A,Nesebar,BG.BG-ExEA.AQ,2019-11-10 23:00:00+01:00,2019-11-11 00:00:00+01:00,2019-11-11 01:29:21+01:00,+01:00,,-1,1,27,ug/m3\r\n"

  setup do
    bypass = Bypass.open()

    Application.put_env(
      :breethe,
      :eea_endpoint,
      "http://localhost:#{bypass.port}/eea"
    )

    {:ok, bypass: bypass}
  end

  describe "download data:" do
    test "for a list of countries and params", %{bypass: bypass} do
      for country <- EEA.country_codes(), param <- EEA.parameters() do
        Bypass.expect_once(bypass, "GET", "/eea/#{country}_#{param}.csv", fn conn ->
          Plug.Conn.resp(
            conn,
            200,
            ""
          )
        end)
      end

      res = EEA.get_data()

      assert length(res) == 144
    end
  end
end
