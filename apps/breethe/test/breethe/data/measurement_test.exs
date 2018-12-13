defmodule Breethe.Data.MeasurementTest do
  use Breethe.DataCase
  alias Breethe.Data.Measurement

  @valid_attrs %{
    location_id: 1,
    parameter: :pm10,
    measured_at: DateTime.utc_now(),
    value: 0,
    quality_index: :very_low
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Measurement.changeset(%Measurement{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Measurement.changeset(%Measurement{}, @invalid_attrs)

    refute changeset.valid?
  end
end
