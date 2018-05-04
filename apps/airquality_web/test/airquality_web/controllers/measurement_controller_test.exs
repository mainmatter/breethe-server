defmodule AirqualityWeb.MeasurementControllerTest do
  use AirqualityWeb.ConnCase

  import Mox
  import Airquality.Factory

  alias Airquality.Sources.OpenAQMock, as: Mock

  setup :verify_on_exit!

  describe "returns measurements" do
    test "when filtering by location id" do
      Mock
      |> expect(:get_latest_measurements, fn _id -> build_list(1, :measurement) end)

      conn = get(build_conn(), "api/locations/1/measurements", [])

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "attributes" => %{
                     "parameter" => "pm10",
                     "unit" => "ppm",
                     "value" => 13.2,
                     "measured-at" => "2019-01-01T00:00:00.000000Z"
                   },
                   "id" => "",
                   "type" => "measurement"
                 },
                 %{
                   "attributes" => %{
                     "measured-at" => nil,
                     "parameter" => "pm25",
                     "unit" => nil,
                     "value" => nil
                   },
                   "id" => "",
                   "type" => "measurement"
                 },
                 %{
                   "attributes" => %{
                     "measured-at" => nil,
                     "parameter" => "so2",
                     "unit" => nil,
                     "value" => nil
                   },
                   "id" => "",
                   "type" => "measurement"
                 },
                 %{
                   "attributes" => %{
                     "measured-at" => nil,
                     "parameter" => "no2",
                     "unit" => nil,
                     "value" => nil
                   },
                   "id" => "",
                   "type" => "measurement"
                 },
                 %{
                   "attributes" => %{
                     "measured-at" => nil,
                     "parameter" => "o3",
                     "unit" => nil,
                     "value" => nil
                   },
                   "id" => "",
                   "type" => "measurement"
                 },
                 %{
                   "attributes" => %{
                     "measured-at" => nil,
                     "parameter" => "co",
                     "unit" => nil,
                     "value" => nil
                   },
                   "id" => "",
                   "type" => "measurement"
                 },
                 %{
                   "attributes" => %{
                     "measured-at" => nil,
                     "parameter" => "bc",
                     "unit" => nil,
                     "value" => nil
                   },
                   "id" => "",
                   "type" => "measurement"
                 }
               ],
               "jsonapi" => %{"version" => "1.0"}
             }
    end
  end
end
