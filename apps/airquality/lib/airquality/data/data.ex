defmodule Airquality.Data do
  alias __MODULE__.{Location, Measurement}
  alias Airquality.Repo

  def get_location(id) do
    Location
    |> Repo.get(id)
    |> Repo.preload(
      measurements:
        Measurement
        |> Measurement.last_24h()
        |> Measurement.one_per_parameter()
        |> Measurement.most_recent_first()
    )
  end

  defp find_location(params) do
    Location
    |> Repo.get_by(Map.take(params, [:city, :coordinates, :identifier, :country]))
    |> Repo.preload(:measurements)
  end

  def find_locations(search_term) do
    Location
    |> Location.matches(search_term)
    |> Location.first_ten()
    |> Repo.all()
  end

  def find_locations(lat, lon) do
    Location
    |> Location.within_meters(lat, lon, 1000)
    |> Location.closest_first(lat, lon)
    |> Location.first_ten()
    |> Repo.all()
  end

  def create_location(params) do
    case find_location(params) do
      nil -> %Location{}
      location -> location
    end
    |> Location.changeset(params)
    |> Repo.insert_or_update!()
  end

  defp find_measurement(params), do: Repo.get_by(Measurement, params)

  def find_measurements(location_id) do
    Measurement
    |> Measurement.for_location(location_id)
    |> Repo.all()
  end

  def create_measurement(params) do
    params
    |> Map.take([:parameter, :measured_at, :location_id])
    |> find_measurement()
    |> case do
      nil -> %Measurement{}
      measurement -> measurement
    end
    |> Measurement.changeset(params)
    |> Repo.insert_or_update!()
  end
end
