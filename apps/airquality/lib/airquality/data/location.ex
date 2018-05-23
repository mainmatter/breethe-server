defmodule Airquality.Data.Location do
  use Ecto.Schema

  import Ecto.{Changeset, Query}
  import Geo.PostGIS

  alias Airquality.Data.{Location, Measurement}

  schema "locations" do
    has_many(:measurements, Measurement)

    field(:identifier, :string)
    field(:city, :string)
    field(:country, :string)
    field(:last_updated, :utc_datetime)
    field(:available_parameters, {:array, ParameterEnum})
    field(:coordinates, Geo.Geometry)

    timestamps()
  end

  @doc false
  def changeset(%Location{} = location, attrs) do
    location
    |> cast(attrs, [
      :identifier,
      :city,
      :country,
      :last_updated,
      :available_parameters,
      :coordinates
    ])
    |> validate_required([:identifier, :city, :country, :available_parameters, :coordinates])
    |> unique_constraint(:identifier)
  end

  def matches(query, search_term) do
    search_term = "%" <> search_term <> "%"

    from(l in query, where: ilike(l.identifier, ^search_term) or ilike(l.city, ^search_term))
  end

  def within_meters(query, lat, lon, 1000) do
    search_term = geo_from_coordinates(lat, lon)

    from(l in query, where: st_dwithin_in_meters(l.coordinates, ^search_term, 1000))
  end

  def closest_first(query, lat, lon) do
    search_term = geo_from_coordinates(lat, lon)

    from(l in query, order_by: st_distance(l.coordinates, ^search_term))
  end

  def first_ten(query) do
    from(l in query, limit: 10)
  end

  defp geo_from_coordinates(lat, lon) do
    %Geo.Point{coordinates: {lat, lon}, srid: 4326}
  end
end
