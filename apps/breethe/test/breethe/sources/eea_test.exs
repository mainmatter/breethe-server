defmodule Breethe.Sources.EEATest do
  use Breethe.DataCase

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
      for country <- EEA.country_codes(), param <- EEA.parameters() do
        Bypass.expect_once(bypass, "GET", "/eea/#{country}_#{param}.csv", fn conn ->
          Plug.Conn.resp(
            conn,
            200,
            ""
          )
        end)
      end

      result = EEA.get_data()
      assert length(result) == 144
    end
  end
end
