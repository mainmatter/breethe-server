defmodule Airquality.DataTest do
  use Airquality.DataCase

  import Airquality.Factory

  alias Airquality.{Data, Repo}
  alias Airquality.Data.{Location, Measurement}

  describe "get_location(id):" do
    test "returns a location by id" do
      location = insert(:location)

      assert location == Data.get_location(location.id)
    end
  end

  describe "find_locations(search_term):" do
    test "returns results containing the search_term in identifier" do
      insert(:location, identifier: "Portland Near Road")
      insert(:location, identifier: "portland pearl")
      ignored_location = insert(:location, identifier: "London Camden")

      locations = Data.find_locations("Portland")

      assert Enum.count(locations) == 2

      Enum.map(locations, fn location ->
        refute location == ignored_location
      end)
    end

    test "returns results containing search_term in city" do
      insert(:location, city: "London")
      insert(:location, identifier: "London Camden")
      ignored_location = insert(:location, city: "Portland")

      locations = Data.find_locations("London")

      assert Enum.count(locations) == 2

      Enum.map(locations, fn location ->
        refute location == ignored_location
      end)
    end

    test "returns a maximum of 10 results" do
      insert_list(11, :location, city: "London")

      locations = Data.find_locations("London")

      assert Enum.count(locations) == 10
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
        insert(:location, coordinates: %Geo.Point{coordinates: {0.0, 0.0}, srid: 4326})

      furthest_location =
        insert(:location, coordinates: %Geo.Point{coordinates: {0.003, 0.001}, srid: 4326})

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

      assert Repo.get_by(Location, params) == location
    end

    test "updates if location already exists" do
      params = params_for(:location, last_updated: DateTime.utc_now())
      location = insert(:location, %{identifier: params.identifier})

      updated_location = Data.create_location(params)

      assert params.last_updated == updated_location.last_updated
      assert location.id == updated_location.id
    end
  end

  describe "create_measurement(params):" do
    test "creates a measurement" do
      location = insert(:location)
      params = params_for(:measurement, location: location)

      measurement = Data.create_measurement(params)

      assert Repo.get_by(Measurement, params) == measurement
    end

    test "updates (no-op) if measurement already exists" do
      params = params_for(:measurement)
      location = insert(:location)
      measurement = insert(:measurement, location: location)

      created_measurement =
        Data.create_measurement(params)
        |> Repo.preload(:location)

      assert measurement == created_measurement
    end
  end
end
