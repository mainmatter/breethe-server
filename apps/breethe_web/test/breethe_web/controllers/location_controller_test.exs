defmodule BreetheWeb.LocationControllerTest do
  use BreetheWeb.ConnCase

  import Mox
  import Breethe.Factory

  alias Breethe.Mock

  setup :verify_on_exit!

  describe "index route: returns locations" do
    test "when filtering by location name" do
      location = insert(:location, measurements: [])

      measured_at = 
        location.last_updated
        |> Map.put(:microsecond, {0, 0})
        |> DateTime.to_iso8601()

      Mock
      |> expect(:search_locations, fn _search_term -> [location] end)

      conn = get(build_conn(), "api/locations?filter[name]=London", [])

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "attributes" => %{
                     "name" => location.identifier,
                     "label" => location.label,
                     "city" => "test-city",
                     "coordinates" => [10.0, 20.0],
                     "country" => "test-country",
                     "lastUpdated" => measured_at
                   },
                   "relationships" => %{
                     "measurements" => %{
                       "links" => %{"related" => "/locations/#{location.id}/measurements"}
                     }
                   },
                   "id" => "#{location.id}",
                   "type" => "location"
                 }
               ],
               "jsonapi" => %{"version" => "1.0"}
             }
    end

    test "when filtering by coordinates (lat/lon)" do
      location = insert(:location, measurements: [])
 
      measured_at = 
        location.last_updated
        |> Map.put(:microsecond, {0, 0})
        |> DateTime.to_iso8601()

      Mock
      |> expect(:search_locations, fn _lat, _lon -> [location] end)

      conn = get(build_conn(), "api/locations?filter[coordinates]=20.3,10", [])

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "attributes" => %{
                     "name" => location.identifier,
                     "label" => location.label,
                     "city" => "test-city",
                     "coordinates" => [10.0, 20.0],
                     "country" => "test-country",
                     "lastUpdated" => measured_at
                   },
                   "relationships" => %{
                     "measurements" => %{
                       "links" => %{"related" => "/locations/#{location.id}/measurements"}
                     }
                   },
                   "id" => "#{location.id}",
                   "type" => "location"
                 }
               ],
               "jsonapi" => %{"version" => "1.0"}
             }
    end

    @tag :skip
    test "and includes measurements in payload" do
      location = insert(:location)
      measurement = insert(:measurement, location_id: location.id)

      Mock
      |> expect(:search_locations, fn _search_term ->
        [%{location | measurements: measurement}]
      end)

      conn = get(build_conn(), "api/locations?filter[name]=London", [])

      assert json_response(conn, 200) == %{
               "data" => [
                 %{
                   "attributes" => %{
                     "name" => location.identifier,
                     "label" => location.label,
                     "city" => "test-city",
                     "coordinates" => [10.0, 20.0],
                     "country" => "test-country",
                     "lastUpdated" => "2200-01-01T00:00:00Z"
                   },
                   "relationships" => %{
                     "measurements" => %{
                       "links" => %{"related" => "/locations/#{location.id}/measurements"},
                       "data" => %{
                         "id" => "#{measurement.id}",
                         "type" => "measurement"
                       }
                     }
                   },
                   "id" => "#{location.id}",
                   "type" => "location"
                 }
               ],
               "included" => [
                 %{
                   "attributes" => %{
                     "measuredAt" => "2200-01-01T00:00:00Z",
                     "parameter" => "pm10",
                     "qualityIndex" => "very_low",
                     "unit" => "micro_grams_m3",
                     "value" => 0.0
                   },
                   "id" => "#{measurement.id}",
                   "relationships" => %{
                     "location" => %{"data" => %{"id" => "#{location.id}", "type" => "location"}}
                   },
                   "type" => "measurement"
                 }
               ],
               "jsonapi" => %{"version" => "1.0"}
             }
    end
  end

  describe "show route: returns location" do
    test "by id" do
      location = insert(:location, measurements: [])

      measured_at = 
        location.last_updated
        |> Map.put(:microsecond, {0, 0})
        |> DateTime.to_iso8601()

      Mock
      |> expect(:get_location, fn _location_id -> location end)

      conn = get(build_conn(), "api/locations/#{location.id}", [])

      assert json_response(conn, 200) == %{
               "data" => %{
                 "attributes" => %{
                   "name" => location.identifier,
                   "label" => location.label,
                   "city" => "test-city",
                   "coordinates" => [10.0, 20.0],
                   "country" => "test-country",
                   "lastUpdated" => measured_at
                 },
                 "relationships" => %{
                   "measurements" => %{
                     "links" => %{"related" => "/locations/#{location.id}/measurements"}
                   }
                 },
                 "id" => "#{location.id}",
                 "type" => "location"
               },
               "jsonapi" => %{"version" => "1.0"}
             }
    end

    @tag :skip
    test "and includes measurements in payload" do
      location = insert(:location)
      measurement = insert(:measurement, location_id: location.id)

      Mock
      |> expect(:get_location, fn _location_id -> %{location | measurements: measurement} end)

      conn = get(build_conn(), "api/locations/#{location.id}", [])

      assert json_response(conn, 200) == %{
               "data" => %{
                 "attributes" => %{
                   "name" => location.identifier,
                   "label" => location.label,
                   "city" => "test-city",
                   "coordinates" => [10.0, 20.0],
                   "country" => "test-country",
                   "lastUpdated" => "2200-01-01T00:00:00Z"
                 },
                 "relationships" => %{
                   "measurements" => %{
                     "links" => %{"related" => "/locations/#{location.id}/measurements"},
                     "data" => %{
                       "id" => "#{measurement.id}",
                       "type" => "measurement"
                     }
                   }
                 },
                 "id" => "#{location.id}",
                 "type" => "location"
               },
               "included" => [
                 %{
                   "attributes" => %{
                     "measuredAt" => "2200-01-01T00:00:00Z",
                     "parameter" => "pm10",
                     "qualityIndex" => "very_low",
                     "unit" => "micro_grams_m3",
                     "value" => 0.0
                   },
                   "id" => "#{measurement.id}",
                   "relationships" => %{
                     "location" => %{"data" => %{"id" => "#{location.id}", "type" => "location"}}
                   },
                   "type" => "measurement"
                 }
               ],
               "jsonapi" => %{"version" => "1.0"}
             }
    end
  end
end
