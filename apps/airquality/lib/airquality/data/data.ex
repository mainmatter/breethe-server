defmodule Airquality.Data do
  import Ecto.Query
  import Geo.PostGIS

  alias __MODULE__.{Location, Measurement}
  alias Airquality.Repo

  def get_location(id), do: Repo.get(Location, id)

  defp find_location(params) do
    Location
    |> Repo.get_by(Map.take(params, [:city, :coordinates, :identifier, :country]))
    |> Repo.preload(:measurements)
  end

  def find_locations(search_term) do
    search_term = "%" <> search_term <> "%"

    Repo.all(
      from(
        l in Location,
        where: ilike(l.identifier, ^search_term) or ilike(l.city, ^search_term),
        limit: 10
      )
    )
  end

  def find_locations(lat, lon) do
    search_term = %Geo.Point{coordinates: {lat, lon}, srid: 4326}

    Repo.all(
      from(
        l in Location,
        where: st_dwithin_in_meters(l.coordinates, ^search_term, 1000),
        order_by: st_distance(l.coordinates, ^search_term),
        limit: 10
      )
    )
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

  def create_measurement(params) do
    params
    |> Map.take([:parameter, :measured_at])
    |> find_measurement()
    |> case do
      nil -> %Measurement{}
      measurement -> measurement
    end
    |> Measurement.changeset(params)
    |> Repo.insert_or_update!()
  end
end
