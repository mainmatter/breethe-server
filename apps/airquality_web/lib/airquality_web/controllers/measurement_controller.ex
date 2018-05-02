defmodule AirqualityWeb.MeasurementController do
  use AirqualityWeb, :controller

  @source Application.get_env(:airquality, :source)

  def index(conn, %{"filter" => %{"location" => location_id}}) do
    measurements =
      location_id
      |> String.to_integer()
      |> @source.get_latest_measurements()

    render(conn, "index.json-api", data: measurements)
  end
end
