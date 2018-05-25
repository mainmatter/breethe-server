defmodule AirqualityWeb.LocationController do
  use AirqualityWeb, :controller

  @source Application.get_env(:airquality_web, :source)

  def index(conn, %{"filter" => filter}) do
    locations =
      case process_params(filter) do
        [lat, lon] -> @source.search_locations(lat, lon)
        name -> @source.search_locations(name)
      end

    _opts =
      locations
      |> Enum.all?(fn location -> location.measurements == [] end)
      |> case do
        true -> []
        false -> [include: "measurements"]
      end

    render(conn, "index.json-api", data: locations, opts: [])
  end

  def show(conn, %{"id" => id}) do
    location =
      id
      |> String.to_integer()
      |> @source.get_location()

    _opts =
      case location.measurements do
        [] -> []
        _ -> [include: "measurements"]
      end

    render(conn, "show.json-api", data: location, opts: [])
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
