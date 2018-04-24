defmodule AirqualityWeb.LocationController do
  use AirqualityWeb, :controller
  @open_aq_api Application.get_env(:airquality, :open_aq)

  require IEx

  def index(conn, %{"filter" => filter}) do
    locations =
      case process_params(filter) do
        [lat, lon] -> @open_aq_api.get_locations(lat, lon)
        name -> @open_aq_api.get_locations(name)
      end

    render(conn, "index.json-api", data: locations)
  end

  defp process_params(%{"name" => name}), do: name

  defp process_params(%{"coordinates" => coordinates}) do
    coordinates
    |> String.split(",")
    |> Enum.map(&parse_float/1)
  end

  defp parse_float(string) do
    # if remainder not "" - might want to raise.
    {float, _remainder} = Float.parse(string)
    float
  end
end
