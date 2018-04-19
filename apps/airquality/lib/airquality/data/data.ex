defmodule Airquality.Data do
  alias __MODULE__.{Measurement, Location}
  alias Airquality.Repo

  def get_location(lat, lon) do
    Repo.get_by(Location, coordinates: %Geo.Point{coordinates: {lat, lon}, srid: 4326})
  end

  def create_measurement(params) do
    %Measurement{}
    |> Measurement.changeset(params)
    |> Repo.insert!()
  end

  def add_coordinates(params, lat, lon) do
    Map.put_new(params, :coordinates, %Geo.Point{coordinates: {lat, lon}, srid: 4326})
  end
end
