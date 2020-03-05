defmodule Breethe do
  @moduledoc """
  Breethe keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @behaviour Breethe.Behaviour

  alias __MODULE__.{Data, TaskSupervisor}

  @source Application.get_env(:breethe, :source)

  defmodule Behaviour do
    @callback get_location(location_id :: integer) :: %Breethe.Data.Location{}
    @callback search_locations(search_term :: String.t()) :: [%Breethe.Data.Location{}]
    @callback search_locations(lat :: number, lon :: number) :: [%Breethe.Data.Location{}]
    @callback search_measurements(location_id :: integer | String.t()) :: [
                %Breethe.Data.Measurement{}
              ]
  end

  def get_location(location_id) do
    location = Data.get_location(location_id)

    {:ok, _pid} =
      Task.Supervisor.start_child(TaskSupervisor, fn ->
        @source.get_latest_measurements(location_id)
      end)

    location
  end

  def search_locations(search_term) do
    locations = Data.find_locations(search_term)

    case length(locations) > 9 do
      false ->
        locations = @source.get_locations(search_term)
        {:ok, _pid} = start_measurement_task(locations)

        locations

      true ->
        {:ok, _pid} =
          Task.Supervisor.start_child(TaskSupervisor, fn ->
            @source.get_locations(search_term)
          end)

        {:ok, _pid} = start_measurement_task(locations)

        locations
    end
  end

  def search_locations(lat, lon) do
    locations = Data.find_locations(lat, lon)

    case length(locations) > 9 do
      false ->
        locations = @source.get_locations(lat, lon)
        {:ok, _pid} = start_measurement_task(locations)

        locations

      true ->
        {:ok, _pid} =
          Task.Supervisor.start_child(TaskSupervisor, fn ->
            @source.get_locations(lat, lon)
          end)

        {:ok, _pid} = start_measurement_task(locations)

        locations
    end
  end

  def search_measurements(location_id) do
    location_id
    |> Data.find_measurements()
    |> case do
      [] ->
        @source.get_latest_measurements(location_id)

      measurements ->
        {:ok, _pid} =
          Task.Supervisor.start_child(TaskSupervisor, fn ->
            @source.get_latest_measurements(location_id)
          end)

        measurements
    end
  end

  defp start_measurement_task(locations) do
    Task.Supervisor.start_child(TaskSupervisor, fn ->
      Enum.map(locations, fn location ->
        @source.get_latest_measurements(location.id)
      end)
    end)
  end
end
