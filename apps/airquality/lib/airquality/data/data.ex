defmodule Airquality.Data do
  alias __MODULE__.{Location, Measurement}
  alias Airquality.Repo

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

  defp compute_caqi(%{parameter: "pm10", value: value} = params) do
    value = round(value)

    index =
      cond do
        value < 25 -> :very_low
        value in 25..50 -> :low
        value in 50..89 -> :medium
        value in 90..179 -> :high
        value >= 180 -> :very_high
      end

    Map.put_new(params, :quality_index, index)
  end

  defp compute_caqi(%{parameter: "pm25", value: value} = params) do
    value = round(value)

    index =
      cond do
        value < 15 -> :very_low
        value in 15..29 -> :low
        value in 30..54 -> :medium
        value in 55..110 -> :high
        value >= 110 -> :very_high
      end

    Map.put_new(params, :quality_index, index)
  end

  defp compute_caqi(%{parameter: "so2", value: value} = params) do
    value = round(value)

    index =
      cond do
        value < 50 -> :very_low
        value in 50..99 -> :low
        value in 100..349 -> :medium
        value in 350..499 -> :high
        value >= 500 -> :very_high
      end

    Map.put_new(params, :quality_index, index)
  end

  defp compute_caqi(%{parameter: "no2", value: value} = params) do
    value = round(value)

    index =
      cond do
        value < 50 -> :very_low
        value in 50..99 -> :low
        value in 100..199 -> :medium
        value in 200..399 -> :high
        value >= 400 -> :very_high
      end

    Map.put_new(params, :quality_index, index)
  end

  defp compute_caqi(%{parameter: "o3", value: value} = params) do
    value = round(value)

    index =
      cond do
        value < 60 -> :very_low
        value in 60..119 -> :low
        value in 120..179 -> :medium
        value in 180..239 -> :high
        value >= 240 -> :very_high
      end

    Map.put_new(params, :quality_index, index)
  end

  defp compute_caqi(%{parameter: "co", value: value} = params) do
    value = round(value)

    index =
      cond do
        value < 5000 -> :very_low
        value in 5000..7499 -> :low
        value in 7500..9999 -> :medium
        value in 10_000..19_999 -> :high
        value >= 20_000 -> :very_high
      end

    Map.put_new(params, :quality_index, index)
  end
end
