defmodule Breethe.Data do
  alias __MODULE__.{Location, Measurement}
  alias Breethe.Repo

  def get_location(id) do
    Location
    |> Repo.get(id)
    |> preload_measurements()
  end

  defp find_location_by_identifier(identifier) do
    Location
    |> Repo.get_by(identifier: identifier)
    |> Repo.preload(:measurements)
  end

  def all_locations(), do: Repo.all(Location)

  def find_locations(lat, lon) do
    Location
    |> Location.within_meters(lat, lon, 1000)
    |> Location.closest_first(lat, lon)
    |> Location.first_ten()
    |> Repo.all()
    |> preload_measurements()
  end

  def create_location(params) do
    case find_location_by_identifier(params.identifier) do
      nil -> %Location{}
      location -> location
    end
    |> Location.changeset(params)
    |> Repo.insert_or_update!()
    |> preload_measurements()
  end

  def update_location_label(location, label) do
    location
    |> Location.changeset(%{label: label})
    |> Repo.update!()
  end

  defp preload_measurements(locations) when is_list(locations) do
    locations
    |> Enum.map(fn location ->
      preload_measurements(location)
    end)
  end

  defp preload_measurements(location) do
    location
    |> Repo.preload(
      measurements:
        Measurement
        |> Measurement.last_24h()
        |> Measurement.one_per_parameter()
        |> Measurement.most_recent_first()
    )
  end

  defp find_measurement(params), do: Repo.get_by(Measurement, params)

  def find_measurements(location_id) do
    Measurement
    |> Measurement.for_location(location_id)
    |> Measurement.last_24h()
    |> Measurement.one_per_parameter()
    |> Measurement.most_recent_first()
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
