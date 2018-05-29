defmodule Airquality.Factory do
  use ExMachina.Ecto, repo: Airquality.Repo

  def location_factory do
    identifier = sequence("test-identifier")

    %Airquality.Data.Location{
      identifier: identifier,
      label: identifier,
      city: "test-city",
      country: "test-country",
      last_updated: DateTime.from_naive!(~N[2019-01-01 00:00:00.000000], "Etc/UTC"),
      available_parameters: [:pm10, :pm25, :so2, :no2, :o3, :co, :bc],
      coordinates: %Geo.Point{coordinates: {10.0, 20.0}, srid: 4326}
    }
  end

  def measurement_factory do
    %Airquality.Data.Measurement{
      parameter: "pm10",
      measured_at: DateTime.from_naive!(~N[2019-01-01 00:00:00.000000], "Etc/UTC"),
      value: 0,
      unit: :micro_grams_m3
    }
  end
end
