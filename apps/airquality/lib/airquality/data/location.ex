defmodule Airquality.Data.Location do
  use Ecto.Schema
  import Ecto.Changeset
  alias Airquality.Data.{Location, Measurement}

  schema "locations" do
    has_many :measurements, Measurement

    field :identifier, :string
    field :city, :string
    field :country, :string
    field :last_updated, :utc_datetime
    field :available_parameters, {:array, ParameterEnum}
    field :coordinates, Geo.Geometry

    timestamps()
  end

  @doc false
  def changeset(%Location{} = location, attrs) do
    location
    |> cast(attrs, [:identifier, :city, :country, :last_updated, :available_parameters, :coordinates])
    |> validate_required([:identifier, :city, :country, :available_parameters, :coordinates])
    |> unique_constraint(:identifier)
  end
end
