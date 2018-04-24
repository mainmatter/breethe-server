defmodule AirqualityWeb.LocationView do
  use AirqualityWeb, :view
  use JaSerializer.PhoenixView

  attributes([:city, :country, :last_updated, :coordinates])
end

defimpl JaSerializer.Formatter, for: [Geo.Point] do
  def format(struct), do: Tuple.to_list(struct.coordinates)
end
