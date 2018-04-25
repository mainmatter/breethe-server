defmodule AirqualityWeb.LocationControllerTest do
  use AirqualityWeb.ConnCase

  import Mox
  import Airquality.Factory

  alias Airquality.Sources.OpenAQMock, as: Mock

  setup :verify_on_exit!

  describe "returns locations" do
    test "when filtering by location name" do
      Mock
      |> expect(:get_locations, fn _search_term -> Mock.get_locations(10, 20) end)
      |> expect(:get_locations, fn _lat, _lon -> build_list(1, :location) end)

      conn = get(build_conn(), "api/locations?filter[name]=London", [])

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "attributes" => %{
                     "city" => "test-city",
                     "coordinates" => [10, 20],
                     "country" => "test-country",
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
      Mock
      |> expect(:get_locations, fn _lat, _lon -> build_list(1, :location) end)

      conn = get(build_conn(), "api/locations?filter[coordinates]=20.3,10", [])

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "attributes" => %{
                     "city" => "test-city",
                     "coordinates" => [10, 20],
                     "country" => "test-country",
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
