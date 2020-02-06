defmodule Breethe.Sources.OpenAQ do
  @behaviour __MODULE__.Behaviour

  alias Breethe.{TaskSupervisor, Data}
  alias Breethe.Sources.{Google, OpenAQ}

  require IEx

  defmodule Behaviour do
    @callback get_locations(search_term :: String.t()) :: [%Breethe.Data.Location{}]
    @callback get_locations(lat :: number, lon :: number) :: [%Breethe.Data.Location{}]
    @callback get_latest_measurements(location_id :: integer | String.t()) :: [
                %Breethe.Data.Measurement{}
              ]
  end

  def get_locations(search_term) do
    case Google.Geocoding.find_location(search_term) do
      [lat, lon] -> get_locations(lat, lon)
      [] -> []
    end
  end

  def get_locations(lat, lon) do
    locations = OpenAQ.Locations.get_locations(lat, lon)

    locations
    |> Enum.reject(fn location -> location.label end)
    |> Enum.map(fn location ->
      {location_lat, location_lon} = location.coordinates.coordinates

      {:ok, _pid} =
        Task.Supervisor.start_child(TaskSupervisor, fn ->
          address = Google.Geocoding.find_location(location_lat, location_lon)

          Data.update_location_label(location, address)
        end)
    end)

    locations
  end

  def get_latest_measurements(location_id) do
    OpenAQ.Measurements.get_latest(location_id)
  end
end
