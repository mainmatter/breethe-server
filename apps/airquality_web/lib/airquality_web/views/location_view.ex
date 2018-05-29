defmodule AirqualityWeb.LocationView do
  use AirqualityWeb, :view
  use JaSerializer.PhoenixView

  attributes([:name, :label, :city, :country, :last_updated, :coordinates])

  has_many(
    :measurements,
    serializer: AirqualityWeb.MeasurementView,
    links: [
      related: "/locations/:id/measurements"
    ],
    include: false,
    identifiers: :when_included
  )

  defp name(struct, _conn), do: Map.get(struct, :identifier)

  defp label(struct, _conn) do
    case Map.get(struct, :label) do
      nil -> Map.get(struct, :identifier)
      label -> label
    end
  end
end

defimpl JaSerializer.Formatter, for: [Geo.Point] do
  def format(struct), do: Tuple.to_list(struct.coordinates)
end
