defmodule Airquality.Data do
  import Ecto.Query
  import Geo.PostGIS

  alias Airquality.Repo
  alias __MODULE__.{Location, Measurement}

  def search_locations(search_term) do
    search_term = "%" <> search_term <> "%"

    Repo.all(from(l in Location, where: like(l.identifier, ^search_term)))
  end

  def search_locations(lat, lon) do
    search_term = %Geo.Point{coordinates: {lat, lon}, srid: 4326}

    Repo.all(from(l in Location, where: st_dwithin_in_meters(l.coordinates, ^search_term, 10000)))
  end
end
