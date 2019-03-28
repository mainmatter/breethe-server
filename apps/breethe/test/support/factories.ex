defmodule Breethe.Factory do
  use ExMachina.Ecto, repo: Breethe.Repo

  def location_factory do
    identifier = sequence("test-identifier")

    %Breethe.Data.Location{
      identifier: identifier,
      label: identifier,
      city: "test-city",
      country: "test-country",
      last_updated: DateTime.add(DateTime.utc_now(), -:timer.hours(2), :millisecond),
      available_parameters: [:pm10, :pm25, :so2, :no2, :o3, :co, :bc],
      coordinates: %Geo.Point{coordinates: {10.0, 20.0}, srid: 4326}
    }
  end

  def measurement_factory do
    %Breethe.Data.Measurement{
      parameter: "pm10",
      measured_at: DateTime.add(DateTime.utc_now(), -:timer.hours(2), :millisecond),
      value: 0
    }
  end
end
