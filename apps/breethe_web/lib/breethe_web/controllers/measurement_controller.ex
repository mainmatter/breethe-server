defmodule BreetheWeb.MeasurementController do
  use BreetheWeb, :controller

  @source Application.get_env(:breethe_web, :source)

  def index(conn, %{"location_id" => location_id}) do
    measurements = @source.search_measurements(location_id)

    render(conn, "index.json-api", data: measurements)
  end
end
