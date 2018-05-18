defmodule AirqualityTest do
  use Airquality.DataCase

  import Mox
  import Airquality.Factory

  alias Airquality.Sources.OpenAQMock, as: Mock
  alias Airquality.TaskSupervisor

  setup :set_mox_global
  setup :verify_on_exit!

  describe "search_locations(search_term):" do
    test "returns locations from the API if 9 or less are present in the DB" do
      location = build(:location)

      Mock
      |> expect(:get_locations, fn _search_term -> Mock.get_locations(0.0, 0.0) end)
      |> expect(:get_locations, fn _lat, _lon -> [location] end)

      assert [location] == Airquality.search_locations("pdx")
    end

    test "returns cached locations if 10 or more are present in DB" do
      cached_locations = insert_list(10, :location, %{city: "pdx"})

      Mock
      |> expect(:get_locations, fn _search_term -> Mock.get_locations(0.0, 0.0) end)
      |> expect(:get_locations, fn _lat, _lon -> [cached_locations | insert_pair(:location)] end)

      locations = Airquality.search_locations("pdx")

      # stops background tasks to avoid throwing error when test process exits
      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.each(fn task ->
        Task.Supervisor.terminate_child(TaskSupervisor, task)
      end)

      assert locations == cached_locations
    end

    test "starts a background task to get locations from the API if 10 or more are present in the DB" do
      cached_locations = insert_list(10, :location, %{city: "pdx"})

      Mock
      |> expect(:get_locations, fn _search_term -> Mock.get_locations(0.0, 0.0) end)
      |> expect(:get_locations, fn _lat, _lon -> [cached_locations | insert_pair(:location)] end)

      Airquality.search_locations("pdx")

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)
    end
  end

  describe "search_locations(lat, lon):" do
    test "returns locations from the API if 9 or less are present in the DB" do
      location = build(:location)

      Mock
      |> expect(:get_locations, fn _lat, _lon -> [location] end)

      assert [location] == Airquality.search_locations(0.0, 0.0)
    end

    test "returns cached locations if 10 or more are present in DB" do
      lat = 0.0
      lon = 0.0

      cached_locations =
        insert_list(10, :location, %{coordinates: %Geo.Point{coordinates: {lat, lon}, srid: 4326}})

      Mock
      |> expect(:get_locations, fn _lat, _lon -> [cached_locations | insert_pair(:location)] end)

      locations = Airquality.search_locations(lat, lon)

      # stops background tasks to avoid throwing error when test process exits
      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.each(fn task ->
        Task.Supervisor.terminate_child(TaskSupervisor, task)
      end)

      assert locations == cached_locations
    end

    test "starts a background task to get locations from the API if 10 or more are present in the DB" do
      lat = 0.0
      lon = 0.0

      cached_locations =
        insert_list(10, :location, %{coordinates: %Geo.Point{coordinates: {lat, lon}, srid: 4326}})

      Mock
      |> expect(:get_locations, fn _lat, _lon -> [cached_locations | insert_pair(:location)] end)

      Airquality.search_locations(lat, lon)

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)
    end
  end
end