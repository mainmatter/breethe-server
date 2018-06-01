defmodule Breethe.Sources.OpenAQ do
  @behaviour __MODULE__.Behaviour

  alias Breethe.{TaskSupervisor, Data}
  alias Breethe.Sources.{Google, OpenAQ}

  defmodule Behaviour do
    @moduledoc """
    Defines the behaviour for all implementations of Sources (Sources.HTTPClient, Sources.InMemory, ...)
    """

    @doc "returns a list of locations based on search term"
    @callback get_locations(search_term :: String.t()) :: [%Breethe.Data.Location{}]
    @doc "returns a list of locations based on coordinates (lat/lon)"
    @callback get_locations(lat :: number, lon :: number) :: [%Breethe.Data.Location{}]
    @doc "returns a list of measurements based on location id"
    @callback get_latest_measurements(location_id :: integer | String.t()) :: [
                %Breethe.Data.Measurement{}
              ]
  end

  def get_locations(search_term) do
    [lat, lon] = Google.Geocoding.find_location(search_term)

    get_locations(lat, lon)
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
