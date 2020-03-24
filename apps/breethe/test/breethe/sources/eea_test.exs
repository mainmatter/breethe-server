defmodule Breethe.Sources.EEATest do
  use ExUnit.Case

  alias Breethe.Sources.EEA

  setup do
    bypass = Bypass.open()

    Application.put_env(
      :breethe,
      :eea_endpoint,
      "http://localhost:#{bypass.port}/eea"
    )

    {:ok, bypass: bypass}
  end

  describe "sends request to download data:" do
    test "for a list of countries and params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/eea/files.txt", fn conn ->
        Plug.Conn.resp(
          conn,
          200,
          ""
        )
      end)

      result = EEA.get_data()
    end

    test "for each country and params", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/eea/files.txt", fn conn ->
        Plug.Conn.resp(
          conn,
          200,
          """
          https://discomap.eea.europa.eu/map/fme/latest/AD_CO.csv   
          https://discomap.eea.europa.eu/map/fme/latest/AD_NO2.csv   
          https://discomap.eea.europa.eu/map/fme/latest/AT_CO.csv   
          https://discomap.eea.europa.eu/map/fme/latest/BA_CO.csv   
          https://discomap.eea.europa.eu/map/fme/latest/BA_NO.csv 
          """
        )
      end)

      country_param_pairs = [
        %{country: "AD", params: ["CO", "NO2"]},
        %{country: "AT", params: ["CO"]},
        %{country: "BA", params: ["CO"]}
      ]

      for %{country: country, params: params} <- country_param_pairs, param <- params do
        Bypass.expect_once(bypass, "GET", "/eea/#{country}_#{param}.csv", fn conn ->
          Plug.Conn.resp(
            conn,
            200,
            ""
          )
        end)
      end

      result = EEA.get_data()
      assert length(result) == 4
    end
  end
end
