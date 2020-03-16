defmodule BreetheTest do
  use Breethe.DataCase

  import Mox
  import Breethe.Factory

  alias Breethe.Sources.Google.GeocodingMock

  setup :verify_on_exit!

  describe "get_location(location_id):" do
    test "returns a location by id" do
      location = insert(:location, measurements: [])

      assert location == Breethe.get_location(location.id)
    end
  end

  describe "search_locations(search_term):" do
    test "returns locations for a search term" do
      search_term = "test-city"

      location =
        insert(:location,
          measurements: [],
          coordinates: %Geo.Point{coordinates: {0.0, 0.0}, srid: 4326}
        )

      expect(GeocodingMock, :find_location, fn ^search_term -> [0.0, 0.0] end)

      assert [location] == Breethe.search_locations(search_term)
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
