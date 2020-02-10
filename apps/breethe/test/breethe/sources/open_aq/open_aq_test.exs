defmodule Breethe.Sources.OpenAQTest do
  use Breethe.DataCase

  import Breethe.Factory

  alias Breethe.Sources.OpenAQ
  alias Breethe.TaskSupervisor

  @last_updated DateTime.utc_now()

  @sample_location %{
    "results" => [
      %{
        "location" => "test-location",
        "city" => "test-city",
        "country" => "test-country",
        "lastUpdated" => @last_updated,
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

  @old_sample_location %{
    "location" => "old-test-location",
    "city" => "test-city",
    "country" => "test-country",
    "lastUpdated" => "2017-01-01T00:00:00Z",
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

  @sample_measurement %{
    "results" => [
      %{
        "location" => "test-location",
        "city" => "test-city",
        "country" => "test-country",
        "measurements" => [
          %{
            "parameter" => "pm10",
            "value" => 0,
            "unit" => "µg/m³",
            "lastUpdated" => @last_updated
          },
          %{
            "parameter" => "no2",
            "value" => 0,
            "unit" => "µg/m³",
            "lastUpdated" => @last_updated
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
      :breethe,
      :google_maps_api_endpoint,
      "http://localhost:#{bypass.port}/google-maps"
    )

    Application.put_env(
      :breethe,
      :open_aq_api_endpoint,
      "http://localhost:#{bypass.port}/open-aq"
    )

    {:ok, bypass: bypass}
  end

  describe "load location data on demand:" do
    test "by latitude and longitude", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/open-aq/locations", fn conn ->
        assert %{"order_by" => "distance", "limit" => "10", "coordinates" => "10,20"} ==
                 URI.decode_query(conn.query_string)

        Plug.Conn.resp(conn, 200, Jason.encode!(@sample_location))
      end)

      [location] = OpenAQ.get_locations(10, 20)

      stop_background_tasks()

      assert location.identifier == "test-location"
      assert location.label == nil
      assert location.city == "test-city"
      assert location.country == "test-country"
      assert location.last_updated == Map.put(@last_updated, :microsecond, {0, 0})
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
                 "key" => Application.get_env(:breethe, :google_maps_api_key)
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

        Plug.Conn.resp(conn, 200, Jason.encode!(response))
      end)

      Bypass.expect(bypass, "GET", "/open-aq/locations", fn conn ->
        assert %{"order_by" => "distance", "limit" => "10", "coordinates" => "10,20"} ==
                 URI.decode_query(conn.query_string)

        Plug.Conn.resp(conn, 200, Jason.encode!(@sample_location))
      end)

      [location] = OpenAQ.get_locations("marienplatz münchen")

      stop_background_tasks()

      assert location.identifier == "test-location"
    end

    test "returns first location by search term if there are multiple results", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/google-maps", fn conn ->
        assert %{
                 "address" => "marienplatz münchen",
                 "key" => Application.get_env(:breethe, :google_maps_api_key)
               } == URI.decode_query(conn.query_string)

        response = %{
          "results" => [
            %{
              "geometry" => %{
                "location" => %{"lat" => 10, "lng" => 20}
              }
            },
            %{
              "geometry" => %{
                "location" => %{"lat" => 12, "lng" => 20}
              }
            }
          ]
        }

        Plug.Conn.resp(conn, 200, Jason.encode!(response))
      end)

      Bypass.expect(bypass, "GET", "/open-aq/locations", fn conn ->
        assert %{"order_by" => "distance", "limit" => "10", "coordinates" => "10,20"} ==
                 URI.decode_query(conn.query_string)

        Plug.Conn.resp(conn, 200, Jason.encode!(@sample_location))
      end)

      locations = OpenAQ.get_locations("marienplatz münchen")

      stop_background_tasks()

      assert length(locations) == 1
      assert List.first(locations).identifier == "test-location"
    end

    test "returns [] for location by search term if there are no results", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/google-maps", fn conn ->
        assert %{
                 "address" => "marienplatz münchen",
                 "key" => Application.get_env(:breethe, :google_maps_api_key)
               } == URI.decode_query(conn.query_string)

        response = %{"results" => []}

        Plug.Conn.resp(conn, 200, Jason.encode!(response))
      end)

      locations = OpenAQ.get_locations("marienplatz münchen")

      stop_background_tasks()

      assert locations == []
    end

    test "ignores locations not updated in the last 7 days", %{bypass: bypass} do
      results =
        @sample_location
        |> update_in(["results"], &(&1 ++ [@old_sample_location]))
        |> Jason.encode!()

      Bypass.expect(bypass, "GET", "/open-aq/locations", fn conn ->
        Plug.Conn.resp(
          conn,
          200,
          results
        )
      end)

      locations = OpenAQ.get_locations(10, 20)

      stop_background_tasks()

      assert Enum.count(locations) == 1

      assert List.first(locations).last_updated == Map.put(@last_updated, :microsecond, {0, 0})
    end

    test "starts a background task to update each location's label", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/open-aq/locations", fn conn ->
        Plug.Conn.resp(
          conn,
          200,
          Jason.encode!(@sample_location)
        )
      end)

      Bypass.expect(bypass, "GET", "/google-maps", fn conn ->
        response = %{
          "results" => [%{"formatted_address" => "test address"}]
        }

        Plug.Conn.resp(conn, 200, Jason.encode!(response))
      end)

      OpenAQ.get_locations(10, 20)

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)
    end
  end

  describe "load ppm data on demand:" do
    test "based on location id", %{
      bypass: bypass
    } do
      location = insert(:location)

      Bypass.expect(bypass, "GET", "/open-aq/latest", fn conn ->
        assert %{"location" => location.identifier} == URI.decode_query(conn.query_string)

        Plug.Conn.resp(conn, 200, Jason.encode!(@sample_measurement))
      end)

      measurements = OpenAQ.get_latest_measurements(location.id)

      [
        %Breethe.Data.Measurement{
          location_id: location1,
          measured_at: measured_at1,
          parameter: parameter1,
          value: value1
        },
        %Breethe.Data.Measurement{
          location_id: location2,
          measured_at: measured_at2,
          parameter: parameter2,
          value: value2
        }
      ] = measurements

      assert location1 == location2 && location2 == location.id
      assert measured_at1 == measured_at2

      assert :eq == DateTime.compare(measured_at2, Map.put(@last_updated, :microsecond, {0, 0}))

      assert parameter1 == :pm10
      assert parameter2 == :no2
      assert value1 == value2 && value1 == 0
    end

    test "returns empty list if no measurements for a location are available", %{bypass: bypass} do
      location = insert(:location)

      Bypass.expect(bypass, "GET", "/open-aq/latest", fn conn ->
        assert %{"location" => location.identifier} == URI.decode_query(conn.query_string)

        Plug.Conn.resp(conn, 200, Jason.encode!(%{"results" => []}))
      end)

      assert [] == OpenAQ.get_latest_measurements(location.id)
    end
  end

  defp stop_background_tasks() do
    TaskSupervisor
    |> Task.Supervisor.children()
    |> Enum.each(fn task ->
      Task.Supervisor.terminate_child(TaskSupervisor, task)
    end)
  end
end
