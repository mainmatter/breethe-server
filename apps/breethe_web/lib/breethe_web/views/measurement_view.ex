defmodule BreetheWeb.MeasurementView do
  use BreetheWeb, :view
  use JaSerializer.PhoenixView

  @caqi_scale %{
    pm10: %{very_low: 25, low: 25..49, medium: 50..89, high: 90..180, very_high: 180},
    pm25: %{very_low: 15, low: 15..29, medium: 30..54, high: 55..110, very_high: 110},
    so2: %{very_low: 50, low: 50..99, medium: 100..349, high: 350..500, very_high: 500},
    no2: %{very_low: 50, low: 50..99, medium: 100..199, high: 200..400, very_high: 400},
    o3: %{very_low: 60, low: 60..119, medium: 120..179, high: 180..240, very_high: 240},
    co: %{
      very_low: 5000,
      low: 5000..7499,
      medium: 7500..9999,
      high: 10_000..20_000,
      very_high: 20_000
    }
  }

  attributes([:parameter, :value, :unit, :measured_at, :quality_index])

  def relationships(measurement, conn) do
    %{
      location: %HasOne{
        serializer: BreetheWeb.LocationView,
        type: "location",
        data: measurement.location
      }
    }
  end

  def unit(_struct, _conn) do
    "micro_grams_m3"
  end

  def quality_index(struct, _conn) do
    struct
    |> Map.get(:value)
    |> case do
      nil -> nil
      value -> compute_caqi(struct.parameter, value)
    end
  end

  defp compute_caqi(parameter, value) do
    value = round(value)
    scale = @caqi_scale[parameter]

    cond do
      value < scale.very_low -> :very_low
      value in scale.low -> :low
      value in scale.medium -> :medium
      value in scale.high -> :high
      value > scale.very_high -> :very_high
    end
  end
end
