defmodule AirqualityWeb.MeasurementView do
  use AirqualityWeb, :view
  use JaSerializer.PhoenixView

  attributes([:parameter, :value, :unit, :measured_at])
end
