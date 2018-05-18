defmodule Airquality do
  @moduledoc """
  Airquality keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @behaviour Airquality.Behaviour

  alias __MODULE__.{Data, TaskSupervisor}

  @source Application.get_env(:airquality, :source)

  defmodule Behaviour do
    @callback search_locations(search_term :: String.t()) :: [%Airquality.Data.Location{}]
    @callback search_locations(lat :: number, lon :: number) :: [%Airquality.Data.Location{}]
    @callback search_measurements(location_id :: integer | String.t()) :: [
                %Airquality.Data.Measurement{}
              ]
  end

  def search_locations(search_term) do
    locations = Data.find_locations(search_term)

    case length(locations) > 9 do
      false ->
        @source.get_locations(search_term)

      true ->
        {:ok, _pid} =
          Task.Supervisor.start_child(TaskSupervisor, fn ->
            @source.get_locations(search_term)
          end)

        locations
    end
  end

  def search_locations(lat, lon) do
    locations = Data.find_locations(lat, lon)

    case length(locations) > 9 do
      false ->
        @source.get_locations(lat, lon)

      true ->
        {:ok, _pid} =
          Task.Supervisor.start_child(TaskSupervisor, fn ->
            @source.get_locations(lat, lon)
          end)

        locations
    end
  end

  def search_measurements(location_id) do
    location_id
    |> Data.find_measurements()
    |> case do
      [] -> @source.get_latest_measurements(location_id)

      measurements ->
        Task.Supervisor.start_child(TaskSupervisor, fn ->
          @source.get_latest_measurements(location_id)
        end)

        measurements
    end
  end
end
