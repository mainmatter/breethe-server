defmodule Breethe.Data.Measurement do
  use Ecto.Schema

  import Ecto.{Changeset, Query}

  alias Breethe.Data.{Measurement, Location}

  schema "measurements" do
    belongs_to(:location, Location)
    field(:parameter, ParameterEnum)
    field(:measured_at, :utc_datetime)
    field(:value, :float)
    field(:unit, UnitEnum)

    timestamps()
  end

  @doc false
  def changeset(%Measurement{} = measurement, attrs) do
    measurement
    |> cast(attrs, [:location_id, :parameter, :measured_at, :value, :unit])
    |> cast_assoc(:location)
    |> validate_required([:location_id, :parameter, :measured_at, :value, :unit])
  end

  def for_location(query, location_id) do
    from(m in query, where: m.location_id == ^location_id)
  end

  def last_24h(query) do
    from(m in query, where: m.measured_at > ago(24, "hour"))
  end

  def most_recent_first(query) do
    from(m in query, order_by: [desc: m.measured_at])
  end

  def one_per_parameter(query) do
    from(m in query, distinct: m.parameter)
  end
end
