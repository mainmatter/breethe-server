defmodule BreetheTest do
  use Breethe.DataCase

  import Mox
  import Breethe.Factory

  alias Breethe.SourcesMock
  alias Breethe.TaskSupervisor

  setup :set_mox_global
  setup :verify_on_exit!

  describe "get_location(location_id)" do
    test "returns cached location with measurements if present in the DB" do
      cached_location = insert(:location)
      measurement = insert(:measurement, location_id: cached_location.id)
      cached_location = %{cached_location | measurements: [measurement]}

      SourcesMock
      |> stub(:get_latest_measurements, fn _location_id, _lat, _lon -> [] end)

      location = Breethe.get_location(cached_location.id)

      stop_background_tasks()

      assert location == cached_location
    end

    test "returns cached location without measurements if no measurements are present in the DB " do
      cached_location = insert(:location, measurements: [])

      SourcesMock
      |> stub(:get_latest_measurements, fn _location_id, _lat, _lon -> [] end)

      location = Breethe.get_location(cached_location.id)

      stop_background_tasks()

      assert location == cached_location
    end

    test "starts a background task to get measurements for a location from the API" do
      cached_location = insert(:location, measurements: [])

      SourcesMock
      |> expect(:get_latest_measurements, fn _location_id, _lat, _lon ->
        [insert(:measurement, location: cached_location)]
      end)

      Breethe.get_location(cached_location.id)

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)
    end
  end

  describe "search_locations(search_term):" do
    test "queries sources for locations if 9 or less are present in the DB" do
      location = build(:location)

      SourcesMock
      |> expect(:get_locations, fn _search_term -> [location] end)

      locations = Breethe.search_locations("pdx")

      stop_background_tasks()

      assert [location] == locations
    end

    test "returns cached locations if 10 or more are present in DB" do
      cached_locations = insert_list(10, :location, %{city: "pdx", measurements: []})

      SourcesMock
      |> stub(:get_locations, fn _search_term -> [] end)

      locations = Breethe.search_locations("pdx")

      stop_background_tasks()

      assert locations == cached_locations
    end

    test "starts a background task to get locations from the API if 10 or more are present in the DB" do
      cached_locations = insert_list(10, :location, %{city: "pdx"})

      SourcesMock
      |> expect(:get_locations, fn _search_term -> [cached_locations | insert_pair(:location)] end)
      |> stub(:get_latest_measurements, fn _location_id, _lat, _lon ->
        Enum.each(cached_locations, fn location ->
          insert(:measurement, location: location)
        end)
      end)

      Breethe.search_locations("pdx")

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)
    end

    test "starts a background task to get measurements if 9 or less locations are present in the DB" do
      location = build(:location)

      SourcesMock
      |> stub(:get_locations, fn _search_term -> [location] end)
      |> expect(:get_latest_measurements, fn _location_id, _lat, _lon ->
        insert(:measurement, location: location)
      end)

      Breethe.search_locations("pdx")

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)
    end

    test "starts a background task to get measurements if 10 or more locations are present in the DB" do
      cached_locations = insert_list(10, :location, %{city: "pdx", measurements: []})

      SourcesMock
      |> stub(:get_locations, fn _search_term -> [cached_locations | insert_pair(:location)] end)
      |> expect(:get_latest_measurements, 10, fn _location_id, _lat, _lon ->
        Enum.each(cached_locations, fn location ->
          insert(:measurement, location: location)
        end)
      end)

      Breethe.search_locations("pdx")

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
      lat = 0.0
      lon = 0.0

      location = build(:location, %{coordinates: %Geo.Point{coordinates: {lat, lon}, srid: 4326}})

      SourcesMock
      |> expect(:get_locations, fn _lat, _lon -> [location] end)
      |> stub(:get_latest_measurements, fn _location_id, _lat, _lon -> [] end)

      locations = Breethe.search_locations(lat, lon)

      stop_background_tasks()

      assert [location] == locations
    end

    test "returns cached locations if 10 or more are present in DB" do
      lat = 0.0
      lon = 0.0

      cached_locations =
        insert_list(10, :location, %{
          coordinates: %Geo.Point{coordinates: {lat, lon}, srid: 4326},
          measurements: []
        })

      SourcesMock
      |> expect(:get_locations, fn _lat, _lon -> [cached_locations | insert_pair(:location)] end)
      |> stub(:get_latest_measurements, fn _location_id, _lat, _lon -> [] end)

      locations = Breethe.search_locations(lat, lon)

      stop_background_tasks()

      assert locations == cached_locations
    end

    test "starts a background task to get locations from the API if 10 or more are present in the DB" do
      lat = 0.0
      lon = 0.0

      cached_locations =
        insert_list(10, :location, %{coordinates: %Geo.Point{coordinates: {lat, lon}, srid: 4326}})

      SourcesMock
      |> expect(:get_locations, fn _lat, _lon -> [cached_locations | insert_pair(:location)] end)
      |> stub(:get_latest_measurements, fn _location_id, _lat, _lon ->
        Enum.each(cached_locations, fn location ->
          insert(:measurement, location: location)
        end)
      end)

      Breethe.search_locations(lat, lon)

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)
    end

    test "starts a background task to get measurements if 9 or less locations are present in the DB" do
      lat = 0.0
      lon = 0.0

      location =
        insert(:location, %{coordinates: %Geo.Point{coordinates: {lat, lon}, srid: 4326}})

      SourcesMock
      |> stub(:get_locations, fn _lat, _lon -> [location] end)
      |> expect(:get_latest_measurements, fn _location_id, _lat, _lon ->
        insert(:measurement, location: location)
      end)

      Breethe.search_locations(0.0, 0.0)

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)
    end

    test "starts a background task to get measurements if 10 or more locations are present in the DB" do
      lat = 0.0
      lon = 0.0

      cached_locations =
        insert_list(10, :location, %{coordinates: %Geo.Point{coordinates: {lat, lon}, srid: 4326}})

      SourcesMock
      |> stub(:get_locations, fn _lat, _lon -> [cached_locations | insert_pair(:location)] end)
      |> expect(:get_latest_measurements, 10, fn _location_id, _lat, _lon ->
        Enum.each(cached_locations, fn location ->
          insert(:measurement, location: location)
        end)
      end)

      Breethe.search_locations(0.0, 0.0)

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)
    end
  end

  describe "search_measurements(location_id):" do
    test "returns measurements from the API if none are present in the DB" do
      location = insert(:location)

      SourcesMock
      |> expect(:get_latest_measurements, fn _location_id, _lat, _lon ->
        insert(:measurement, location: location)
      end)

      measurement = Breethe.search_measurements(location.id)
      assert measurement.location_id == location.id
    end

    test "returns cached measurements if any are present in DB" do
      location = insert(:location)
      cached_measurement = [insert(:measurement, location_id: location.id)]

      SourcesMock
      |> stub(:get_latest_measurements, fn _location_id, _lat, _lon -> [] end)

      measurements = Breethe.search_measurements(location.id)

      stop_background_tasks()

      assert measurements == cached_measurement
    end

    test "starts a background task to get measurements if any are present in the DB" do
      location = insert(:location)
      insert(:measurement, location: location)

      SourcesMock
      |> expect(:get_latest_measurements, fn _location_id, _lat, _lon ->
        insert(:measurement, location: location)
      end)

      Breethe.search_measurements(location.id)

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)
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
