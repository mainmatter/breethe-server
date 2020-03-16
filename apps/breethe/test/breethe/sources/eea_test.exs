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
      for %{country: country, params: params} <- EEA.countries(), param <- params do
        Bypass.expect_once(bypass, "GET", "/eea/#{country}_#{param}.csv", fn conn ->
          Plug.Conn.resp(
            conn,
            200,
            ""
          )
        end)
      end

      result = EEA.get_data()
      assert length(result) == 203
    end
  end
end
