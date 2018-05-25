defmodule AirqualityWeb.MeasurementControllerTest do
  use AirqualityWeb.ConnCase

  import Mox
  import Airquality.Factory

  alias Airquality.Mock

  setup :verify_on_exit!

  describe "returns measurements" do
    test "when filtering by location id" do
      location = build(:location)
      measurement = insert(:measurement, location: location)

      Mock
      |> expect(:search_measurements, fn _id -> [measurement] end)

      conn = get(build_conn(), "api/locations/#{measurement.location.id}/measurements", [])

      assert json_response(conn, 200) == %{
               "jsonapi" => %{"version" => "1.0"},
               "data" => [
                 %{
                   "attributes" => %{
                     "parameter" => "pm10",
                     "measured-at" => "2019-01-01T00:00:00.000000Z",
                     "quality-index" => "very_low",
                     "unit" => "micro_grams_m3",
                     "value" => 0.0
                   },
                   "relationships" => %{
                     "location" => %{
                       "data" => %{
                         "id" => "#{measurement.location.id}",
                         "type" => "location"
                       }
                     }
                   },
                   "id" => "#{measurement.id}",
                   "type" => "measurement"
                 }
               ]
             }
    end
  end
end
