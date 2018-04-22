defmodule Airquality.Data.MeasurementTest do
  use Airquality.DataCase
  alias Airquality.Data.Measurement

  @valid_attrs %{
    location_id: 1,
    parameter: :pm10,
    measured_at: DateTime.utc_now(),
    value: 1.0,
    unit: :micro_grams_m3
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
