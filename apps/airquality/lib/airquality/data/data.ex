defmodule Airquality.Data do
  alias __MODULE__.{Location, Measurement}
  alias Airquality.Repo

  @caqi_scale %{
    "pm10" => %{very_low: 25, low: 25..49, medium: 50..89, high: 90..180, very_high: 180},
    "pm25" => %{very_low: 15, low: 15..29, medium: 30..54, high: 55..110, very_high: 110},
    "so2" => %{very_low: 50, low: 50..99, medium: 100..349, high: 350..500, very_high: 500},
    "no2" => %{very_low: 50, low: 50..99, medium: 100..199, high: 200..400, very_high: 400},
    "o3" => %{very_low: 60, low: 60..119, medium: 120..179, high: 180..240, very_high: 240},
    "co" => %{
      very_low: 5000,
      low: 5000..7499,
      medium: 7500..9999,
      high: 10_000..20_000,
      very_high: 20_000
    }
  }

  def get_location(id), do: Repo.get(Location, id)

  defp find_location(params) do
    Location
    |> Repo.get_by(Map.take(params, [:city, :coordinates, :identifier, :country]))
    |> Repo.preload(:measurements)
  end

  def create_location(params) do
    case find_location(params) do
      nil -> %Location{}
      location -> location
    end
    |> Location.changeset(params)
    |> Repo.insert_or_update!()
  end

  defp find_measurement(params), do: Repo.get_by(Measurement, params)

  def create_measurement(params) do
    params_with_index = compute_caqi(params)

    params
    |> Map.take([:parameter, :measured_at])
    |> find_measurement()
    |> case do
      nil -> %Measurement{}
      measurement -> measurement
    end
    |> Measurement.changeset(params_with_index)
    |> Repo.insert_or_update!()
  end

  defp compute_caqi(%{parameter: parameter, value: value} = params) do
    value = round(value)
    scale = @caqi_scale[parameter]

    index =
      cond do
        value < scale.very_low -> :very_low
        value in scale.low -> :low
        value in scale.medium -> :medium
        value in scale.high -> :high
        value > scale.very_high -> :very_high
      end

    Map.put_new(params, :quality_index, index)
  end
end
