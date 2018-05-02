defmodule Airquality.Data do
  alias __MODULE__.{Location, Measurement}
  alias Airquality.Repo

  def get_location(id) when is_integer(id), do: Repo.get(Location, id)

  def get_location(params) when is_map(params) do
    Location
    |> Repo.get_by(Map.take(params, [:city, :coordinates, :identifier, :country]))
    |> Repo.preload(:measurements)
  end

  def create_location(params) do
    case get_location(params) do
      nil -> %Location{}
      location -> location
    end
    |> Location.changeset(params)
    |> Repo.insert_or_update!()
  end

  def get_measurement(params), do: Repo.get_by(Measurement, params)

  def create_measurement(params) do
    case get_measurement(params) do
      nil -> %Measurement{}
      measurement -> measurement
    end
    |> Measurement.changeset(params)
    |> Repo.insert_or_update!()
  end
end
