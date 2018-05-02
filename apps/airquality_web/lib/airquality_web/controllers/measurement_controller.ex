defmodule AirqualityWeb.MeasurementController do
  use AirqualityWeb, :controller

  @source Application.get_env(:airquality, :source)
  @parameters [:pm10, :pm25, :so2, :no2, :o3, :co, :bc]

  def index(conn, %{"filter" => %{"location" => location_id}}) do
    measurements = @source.get_latest_measurements(location_id)
    nil_measurements = generate_missing_measurements(measurements)

    render(conn, "index.json-api", data: measurements ++ nil_measurements)
  end

  defp generate_missing_measurements(measurements) do
    measurements
    |> list_missing_parameters()
    |> Enum.map(&add_nil_measurement/1)
  end

  defp list_missing_parameters(measurements) do
    included_parameters = Enum.map(measurements, & &1.parameter)

    @parameters -- included_parameters
  end

  defp add_nil_measurement(param) do
    %{
      parameter: param,
      value: nil,
      unit: nil,
      measured_at: nil
    }
  end
end
