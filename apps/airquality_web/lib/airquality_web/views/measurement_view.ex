defmodule AirqualityWeb.MeasurementView do
  use AirqualityWeb, :view
  use JaSerializer.PhoenixView

  attributes([:parameter, :value, :unit, :measured_at, :quality_index])

  has_one(:location, type: "location", field: :location_id)
end
