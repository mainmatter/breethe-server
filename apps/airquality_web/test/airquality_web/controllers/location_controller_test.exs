defmodule AirqualityWeb.LocationControllerTest do
  use AirqualityWeb.ConnCase

  describe "returns locations" do
    test "when filtering by location name" do
      conn = get(build_conn(), "api/locations?filter[name]=London", [])

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "attributes" => %{
                     "available-parameters" => ["pm10", "pm25", "so2", "no2", "o3", "co", "bc"],
                     "city" => "test-city",
                     "coordinates" => [10, 20],
                     "country" => "test-country",
                     "identifier" => "test-identifier",
                     "last-updated" => "2019-01-01T00:00:00Z"
                   },
                   "id" => "",
                   "type" => "location"
                 }
               ],
               "jsonapi" => %{"version" => "1.0"}
             }
    end

    test "when filtering by coordinates (lat/lon)" do
      conn = get(build_conn(), "api/locations?filter[coordinates]=20.3,10", [])

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "attributes" => %{
                     "available-parameters" => ["pm10", "pm25", "so2", "no2", "o3", "co", "bc"],
                     "city" => "test-city",
                     "coordinates" => [10, 20],
                     "country" => "test-country",
                     "identifier" => "test-identifier",
                     "last-updated" => "2019-01-01T00:00:00Z"
                   },
                   "id" => "",
                   "type" => "location"
                 }
               ],
               "jsonapi" => %{"version" => "1.0"}
             }
    end
  end
end
