defmodule Airquality.Data do
  import Ecto.Query
  import Geo.PostGIS

  alias Airquality.Repo
  alias __MODULE__.{Location, Measurement}

  def get_location(id) when is_integer(id), do: Repo.get(Location, id)

  def get_location(params) when is_map(params),
    do: Repo.get_by(Location, params)

  def create_location(params) do
    case get_location(params) do
      nil -> %Location{}
      location -> location
    end
    |> Location.changeset(params)
    |> Repo.insert_or_update!()
  end

  def get_measurement(params) when is_map(params), do: Repo.get_by(Measurement, params)

  def create_measurement(params) do
    case get_measurement(params) do
      nil -> %Measurement{}
      measurement -> measurement
    end
    |> Measurement.changeset(params)
    |> Repo.insert_or_update!()
  end

  def search_locations(search_term) do
    search_term = "%" <> search_term <> "%"

    Repo.all(from(l in Location, where: ilike(l.identifier, ^search_term)))
  end

  def search_locations(lat, lon) do
    search_term = %Geo.Point{coordinates: {lat, lon}, srid: 4326}

    Repo.all(from(l in Location, where: st_dwithin_in_meters(l.coordinates, ^search_term, 10000)))
  end
end
