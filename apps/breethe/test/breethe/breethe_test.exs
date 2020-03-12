defmodule BreetheTest do
  use Breethe.DataCase

  import Breethe.Factory

  describe "get_location(location_id):" do
    test "returns a location by id" do
      location = insert(:location, measurements: [])

      assert location == Breethe.get_location(location.id)
    end
  end

  describe "search_locations(search_term):" do
    test "returns locations for a search term" do
      location = insert(:location, city: "london", measurements: [])

      assert [location] == Breethe.search_locations("london")
    end
  end

  describe "search_locations(lat, lon):" do
    test "returns locations for latitude and longitude" do
      lat = 0.0
      lon = 0.0

      location =
        insert(:location,
          coordinates: %Geo.Point{coordinates: {lat, lon}, srid: 4326},
          measurements: []
        )

      assert [location] == Breethe.search_locations(lat, lon)
    end
  end

  describe "search_measurements(location_id):" do
    test "returns measurements for a location" do
      location = insert(:location)
      cached_measurement = [insert(:measurement, location_id: location.id)]

      assert cached_measurement == Breethe.search_measurements(location.id)
    end
  end
end
