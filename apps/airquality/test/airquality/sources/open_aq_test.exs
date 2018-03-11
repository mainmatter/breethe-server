defmodule Airquality.Sources.OpenAQTest do
  use Airquality.DataCase
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

  test "it gets locations by latitude and longitude", %{bypass: bypass} do
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
    assert location.coordinates == %Geo.Point{coordinates: {10.12345678, 20.12345678}, srid: 4326}
  end

  test "it gets locations by search term", %{bypass: bypass} do
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
