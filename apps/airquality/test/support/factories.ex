defmodule Airquality.Factory do
  use ExMachina.Ecto, repo: Airquality.Repo

  def location_factory do
    %Airquality.Data.Location{
      identifier: "test-identifier",
      city: "test-city",
      country: "test-country",
      last_updated: Timex.parse!("2019-01-01T00:00:00Z", "{ISO:Extended:Z}"),
      available_parameters: [:pm10, :pm25, :so2, :no2, :o3, :co, :bc],
      coordinates: %Geo.Point{coordinates: {10, 20}, srid: 4326}
    }
  end

  def measurement_factory do
    %Airquality.Data.Measurement{
      parameter: :pm10,
      measured_at: Timex.parse!("2019-01-01T00:00:00Z", "{ISO:Extended:Z}"),
      value: 13.2,
      unit: :ppm
    }
  end
end
