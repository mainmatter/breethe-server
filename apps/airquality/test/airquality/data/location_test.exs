defmodule Airquality.Data.LocationTest do
  use Airquality.DataCase
  import Airquality.Factory

  alias Airquality.Data.Location

  @valid_attrs %{identifier: "identifer", city: "city", country: "country", last_updated: DateTime.utc_now, available_parameters: [:pm10], coordinates: %Geo.Point{coordinates: {1, 2}, srid: 4326}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Location.changeset(%Location{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Location.changeset(%Location{}, @invalid_attrs)

    refute changeset.valid?
  end

  test "changeset with duplicate identifier" do
    insert(:location, @valid_attrs)
    changeset = Location.changeset(%Location{}, @valid_attrs)

    {:error, changeset} = Repo.insert(changeset)
    refute changeset.valid?
  end
end
