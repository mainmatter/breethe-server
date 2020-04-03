defmodule Breethe.Data do
  alias __MODULE__.{Location, Measurement}
  alias Breethe.Repo
  alias Ecto.Multi
  import Ecto.Query, only: [from: 2]

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
    |> Location.within_meters(lat, lon, 10000)
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

  def find_measurements(location_id) do
    Measurement
    |> Measurement.for_location(location_id)
    |> Measurement.last_24h()
    |> Measurement.one_per_parameter()
    |> Measurement.most_recent_first()
    |> Repo.all()
  end

  def import_measurements(location, measurements_params) do
    latest_measurement_date = find_latest_measurement_date(location)

    params =
      measurements_params
      |> Enum.map(fn measurement_params ->
        Map.take(measurement_params, [:parameter, :measured_at, :location_id, :value])
      end)
      |> Enum.filter(&(&1.measured_at > latest_measurement_date))

    result =
      Enum.reduce(params, Multi.new(), fn measurement_params, multi ->
        changeset = Measurement.changeset(%Measurement{}, measurement_params)
        Multi.insert(multi, {:write, measurement_params.measured_at}, changeset)
      end)
      |> Repo.transaction()

    case result do
      {:ok, result} -> result
      {:error, _, changeset, _} -> {:error, changeset}
    end
  end

  def find_latest_measurement_date(location) do
    query = from(m in Measurement, where: m.location_id == ^location.id)
    Repo.aggregate(query, :max, :measured_at)
  end
end
