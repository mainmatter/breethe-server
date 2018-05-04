defmodule Airquality.DataTest do
  use Airquality.DataCase

  import Airquality.Factory

  alias Airquality.{Data, Repo}
  alias Airquality.Data.{Location, Measurement}

  describe "location: " do
    test "get_location by id" do
      location = insert(:location)

      assert location == Data.get_location(location.id)
    end

    test "create_location from params" do
      params = params_for(:location)

      location = Data.create_location(params)

      assert Repo.get_by(Location, params) == location
    end

    test "create_location updates if location already exists" do
      params = params_for(:location, last_updated: DateTime.utc_now())
      location = insert(:location)

      updated_location = Data.create_location(params)

      assert params.last_updated == updated_location.last_updated
      assert location.id == updated_location.id
    end
  end

  describe "measurement: " do
    test "create_measurement from params" do
      location = insert(:location)
      params = params_for(:measurement, location: location)

      measurement = Data.create_measurement(params)

      assert Repo.get_by(Measurement, params) == measurement
    end

    test "create_measurement updates (no-op) if measurement already exists" do
      params = params_for(:measurement)
      location = insert(:location)
      measurement = insert(:measurement, location: location)

      created_measurement = Data.create_measurement(params)
      |> Repo.preload(:location)

      assert measurement == created_measurement
    end
  end
end
