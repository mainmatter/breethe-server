defmodule AirqualityWeb.LocationView do
  use AirqualityWeb, :view
  use JaSerializer.PhoenixView

  attributes([:identifier, :city, :country, :last_updated, :available_parameters, :coordinates])
end

defimpl JaSerializer.Formatter, for: [Geo.Point] do
  def format(struct), do: Tuple.to_list(struct.coordinates)
end
