defmodule Airquality.Sources.OpenAQTest do
  use Airquality.DataCase
  import Airquality.Factory
  alias Airquality.Sources.OpenAQ

  @sample_location %{
    "results" => [
      %{
        "location" => "test-location",
        "city" => "test-city",
        "country" => "test-country",
        "lastUpdated" => "2019-01-01T00:00:00Z",
        "parameters" => [
          "co",
          "o3",
          "no2",
          "pm10",
          "so2",
          "pm25"
        ],
        "coordinates" => %{
          "latitude" => 10.12345678,
          "longitude" => 20.12345678
        }
      }
    ]
  }

  @sample_measurement %{
    "results" => [
      %{
        "location" => "test-location",
        "city" => "test-city",
        "country" => "test-country",
        "measurements" => [
          %{
            "parameter" => "pm10",
            "value" => 14.15,
            "unit" => "µg/m³",
            "lastUpdated" => "2019-01-01T00:00:00Z"
          },
          %{
            "parameter" => "no2",
            "value" => 14.15,
            "unit" => "mg/m³",
            "lastUpdated" => "2019-01-01T00:00:00Z"
          }
        ],
        "coordinates" => %{
          "latitude" => 10.12345678,
          "longitude" => 20.12345678
        }
      }
    ]
  }

  setup do
    bypass = Bypass.open()

    Application.put_env(
      :airquality,
      :google_maps_api_endpoint,
      "http://localhost:#{bypass.port}/google-maps"
    )

    Application.put_env(
      :airquality,
      :open_aq_api_endpoint,
      "http://localhost:#{bypass.port}/open-aq"
    )

    {:ok, bypass: bypass}
  end

  describe "load location data on demand" do
    test "by latitude and longitude", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/open-aq/locations", fn conn ->
        assert %{"nearest" => "100", "coordinates" => "10,20"} ==
                 URI.decode_query(conn.query_string)

        Plug.Conn.resp(conn, 200, Poison.encode!(@sample_location))
      end)

      [location] = OpenAQ.get_locations(10, 20)

      assert location.identifier == "test-location"
      assert location.city == "test-city"
      assert location.country == "test-country"
      assert location.last_updated == Timex.to_datetime({{2019, 1, 1}, {0, 0, 0, 0}})
      assert location.available_parameters == [:co, :o3, :no2, :pm10, :so2, :pm25]

      assert location.coordinates == %Geo.Point{
               coordinates: {10.12345678, 20.12345678},
               srid: 4326
             }
    end

    test "by search term", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/google-maps", fn conn ->
        assert %{
                 "address" => "marienplatz münchen",
                 "key" => Application.get_env(:airquality, :google_maps_api_key)
               } == URI.decode_query(conn.query_string)

        response = %{
          "results" => [
            %{
              "geometry" => %{
                "location" => %{"lat" => 10, "lng" => 20}
              }
            }
          ]
        }

        Plug.Conn.resp(conn, 200, Poison.encode!(response))
      end)

      Bypass.expect(bypass, "GET", "/open-aq/locations", fn conn ->
        assert %{"nearest" => "100", "coordinates" => "10,20"} ==
                 URI.decode_query(conn.query_string)

        Plug.Conn.resp(conn, 200, Poison.encode!(@sample_location))
      end)

      [location] = OpenAQ.get_locations("marienplatz münchen")

      assert location.identifier == "test-location"
    end
  end

  describe "load ppm data on demand" do
    test "based on location id", %{
      bypass: bypass
    } do
      location = insert(:location)

      Bypass.expect(bypass, "GET", "/open-aq/latest", fn conn ->
        assert %{"location" => location.identifier} == URI.decode_query(conn.query_string)

        Plug.Conn.resp(conn, 200, Poison.encode!(@sample_measurement))
      end)

      measurements = OpenAQ.get_latest_measurements(location.id)

      [
        %Airquality.Data.Measurement{
          location_id: location1,
          measured_at: measured_at1,
          parameter: parameter1,
          unit: unit1,
          value: value1
        },
        %Airquality.Data.Measurement{
          location_id: location2,
          measured_at: measured_at2,
          parameter: parameter2,
          unit: unit2,
          value: value2
        }
      ] = measurements

      assert location1 == location2 && location2 == location.id
      assert measured_at1 == measured_at2

      assert :eq ==
               DateTime.compare(measured_at2, Timex.to_datetime({{2019, 1, 1}, {0, 0, 0, 0}}))

      assert parameter1 == :pm10
      assert parameter2 == :no2
      assert unit1 == :micro_grams_m3
      assert unit2 == :milli_grams_m3
      assert value1 == value2 && value2 == 14.15
    end
  end
end
