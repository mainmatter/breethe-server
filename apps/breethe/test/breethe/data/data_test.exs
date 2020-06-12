defmodule Breethe.DataTest do
  use Breethe.DataCase

  import Breethe.Factory

  alias Breethe.{Data, Repo}
  alias Breethe.Data.{Location, Measurement}

  describe "get_location(id):" do
    test "returns a location by id" do
      location = insert(:location, measurements: [])

      assert location == Data.get_location(location.id)
    end

    test "returns a location and associated measurements no older than 24 hours" do
      location = insert(:location)

      insert(
        :measurement,
        measured_at: Timex.shift(DateTime.utc_now(), hours: -25),
        parameter: :no2,
        location_id: location.id
      )

      recent_measurement =
        insert(:measurement, measured_at: DateTime.utc_now(), location_id: location.id)

      location = Data.get_location(location.id)

      assert Enum.count(location.measurements) == 1
      assert List.first(location.measurements) == recent_measurement
    end

    test "returns a location and only the most recent associated measurement per parameter" do
      location = insert(:location)

      latest_measurement =
        insert(:measurement, measured_at: DateTime.utc_now(), location_id: location.id)

      insert(
        :measurement,
        measured_at: Timex.shift(DateTime.utc_now(), hours: -1),
        location_id: location.id
      )

      location = Data.get_location(location.id)

      assert Enum.count(location.measurements) == 1
      assert List.first(location.measurements) == latest_measurement
    end
  end

  describe "find_locations(lat, lon):" do
    test "returns results within 1000 meters of lat, lon" do
      insert(:location, coordinates: %Geo.Point{coordinates: {0.0, 0.0}, srid: 4326})
      insert(:location, coordinates: %Geo.Point{coordinates: {0.001, 0.0}, srid: 4326})

      ignored_location =
        insert(:location, coordinates: %Geo.Point{coordinates: {90.0, 0.0}, srid: 4326})

      locations = Data.find_locations(0.0, 0.0)

      assert Enum.count(locations) == 2

      Enum.map(locations, fn location ->
        refute location == ignored_location
      end)
    end

    test "orders results by closest to lat, lon" do
      closest_location =
        insert(
          :location,
          coordinates: %Geo.Point{coordinates: {0.0, 0.0}, srid: 4326},
          measurements: []
        )

      furthest_location =
        insert(
          :location,
          coordinates: %Geo.Point{coordinates: {0.003, 0.001}, srid: 4326},
          measurements: []
        )

      insert(:location, coordinates: %Geo.Point{coordinates: {0.001, 0.001}, srid: 4326})

      locations = Data.find_locations(0.0, 0.0)

      assert Enum.count(locations) == 3
      assert List.first(locations) == closest_location
      assert List.last(locations) == furthest_location
    end

    test "returns a maximum of 10 results" do
      coordinates = %Geo.Point{coordinates: {0.0, 0.0}, srid: 4326}
      insert_list(11, :location, coordinates: coordinates)

      locations = Data.find_locations(0.0, 0.0)

      assert Enum.count(locations) == 10
    end
  end

  describe "create_location(params):" do
    test "creates a location from params" do
      params = params_for(:location)

      location = Data.create_location(params)

      stored_location =
        Location
        |> Repo.get_by(params)
        |> Repo.preload(:measurements)

      assert stored_location == location
    end

    test "updates if location already exists" do
      now =
        DateTime.utc_now()
        |> DateTime.truncate(:second)

      params = params_for(:location, last_updated: now)
      location = insert(:location, %{identifier: params.identifier, city: "a different city"})

      updated_location = Data.create_location(params)

      assert now == updated_location.last_updated
      assert location.id == updated_location.id
    end
  end

  describe "find_measurement(location_id)" do
    test "returns a measurement by location id" do
      location = insert(:location)
      measurement = insert(:measurement, location_id: location.id)
      insert(:measurement, location: build(:location))

      measurements = Data.find_measurements(location.id)

      assert Enum.count(measurements) == 1
      assert List.first(measurements) == measurement
    end
  end

  describe "create_measurements(params):" do
    test "creates measurements" do
      location = insert(:location)
      params = params_for(:measurement, location: location)

      Data.import_measurements(location, [params])

      assert Repo.aggregate(Measurement, :count) == 1
    end

    test "only inserts new measurements" do
      location = insert(:location)

      insert(:measurement,
        location: location,
        measured_at: Timex.shift(DateTime.utc_now(), days: -1)
      )

      params_old =
        params_for(:measurement,
          location: location,
          measured_at: Timex.shift(DateTime.utc_now(), days: -2)
        )

      params_new = params_for(:measurement, location: location, measured_at: DateTime.utc_now())

      Data.import_measurements(location, [params_old, params_new])

      # params_old was not inserted
      assert Repo.aggregate(Measurement, :count) == 2
    end
  end

  describe "delete_old_data" do
    test "deletes measurements older than the threshold" do
      location = insert(:location)

      insert(:measurement,
        location: location,
        measured_at: DateTime.utc_now()
      )

      insert(:measurement,
        location: location,
        measured_at: Timex.shift(DateTime.utc_now(), days: -4)
      )

      Data.delete_old_data(3)

      assert Repo.aggregate(Measurement, :count) == 1
    end

    test "deletes locations that do not have measurements" do
      empty_location = insert(:location)
      location = insert(:location)
      old_location = insert(:location)

      insert(:measurement,
        location: location,
        measured_at: DateTime.utc_now()
      )

      insert(:measurement,
        location: old_location,
        measured_at: Timex.shift(DateTime.utc_now(), days: -4)
      )

      Data.delete_old_data(3)

      assert Repo.aggregate(Location, :count) == 1
    end
  end
end
