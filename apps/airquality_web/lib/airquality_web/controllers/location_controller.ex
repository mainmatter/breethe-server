defmodule AirqualityWeb.LocationController do
  use AirqualityWeb, :controller

  import Ecto.Query

  alias Airquality.Data

  require IEx

  @source Application.get_env(:airquality, :source)

  def index(conn, %{"filter" => filter}) do
    # 1. search repo
    # 2. launch task as well
    # 3. return locations

    db_locations =
    case process_params(filter) do
      [lat, lon] -> Data.search_locations(lat, lon)
      name -> Data.search_locations(name)
    end

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
