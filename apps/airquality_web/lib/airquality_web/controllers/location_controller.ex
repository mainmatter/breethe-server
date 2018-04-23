defmodule AirqualityWeb.LocationController do
  use AirqualityWeb, :controller
  alias Airquality.Sources.OpenAQ

  def index(conn, %{"filter" => filter}) do
    locations =
      case process_params(filter) do
        [lat, lon] -> OpenAQ.get_locations(lat, lon)
        name -> OpenAQ.get_locations(name)
      end

    render(conn, "index.json-api", data: locations)
  end

  defp process_params(%{"name" => name}), do: name

  defp process_params(%{"coordinates" => coordinates}) do
    coordinates
    |> String.split(",")
    |> Enum.map(&String.to_float/1)
  end
end
