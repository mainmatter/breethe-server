defmodule Airquality.Data do
  alias __MODULE__.{Measurement, Location}
  alias Airquality.Repo

  def get_location(location_id) do
    Repo.get(Location, location_id)
  end

  def create_measurement(params) do
    %Measurement{}
    |> Measurement.changeset(params)
    |> Repo.insert!()
  end
end
