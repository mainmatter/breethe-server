defmodule AirqualityWeb.LocationController do
  use AirqualityWeb, :controller

  @source Application.get_env(:airquality, :source)

  def index(conn, %{"filter" => filter}) do
    locations =
      case process_params(filter) do
        [lat, lon] -> @source.get_locations(lat, lon)
        name -> @source.get_locations(name)
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
    {float, ""} = Float.parse(string)
    float
  end
end
