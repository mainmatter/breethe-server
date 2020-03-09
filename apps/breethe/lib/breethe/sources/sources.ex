defmodule Breethe.Sources do
  @moduledoc """
    This module checks location of query. 
    If in Europe, exits as data should already be in DB. 
    If not in Europe, initiates search through OpenAQ
  """
  alias Breethe.TaskSupervisor
  alias __MODULE__.{Google, EEA}

  @open_aq Application.get_env(:breethe, :open_aq)
  @google Application.get_env(:breethe, :google)

  defmodule Behaviour do
    @callback get_data(cached_locations :: [%Breethe.Data.Location{}], search_term :: String.t()) ::
                [
                  %Breethe.Data.Location{}
                ]
    @callback get_data(
                cached_locations :: [%Breethe.Data.Location{}],
                lat :: number,
                lon :: number
              ) :: [
                %Breethe.Data.Location{}
              ]
  end

  def get_data([], search_term) do
    search_term
    |> @google.find_location_country_code()
    |> (&Enum.member?(EEA.country_codes(), &1)).()
    |> case do
      true -> []
      false -> query_open_aq([], search_term)
    end
  end

  def get_data(cached_locations, search_term) do
    cached_locations
    |> List.first()
    |> Map.fetch!(:source)
    |> case do
      :eea -> cached_locations
      :oaq -> query_open_aq(cached_locations, search_term)
    end
  end

  def get_data([], lat, lon) do
    lat
    |> @google.find_location_country_code(lon)
    |> (&Enum.member?(EEA.country_codes(), &1)).()
    |> case do
      true -> []
      false -> query_open_aq([], lat, lon)
    end
  end

  def get_data(cached_locations, lat, lon) do
    cached_locations
    |> List.first()
    |> Map.fetch!(:source)
    |> case do
      :eea -> cached_locations
      :oaq -> query_open_aq(cached_locations, lat, lon)
    end
  end

  defp query_open_aq([], search_term), do: @open_aq.get_locations(search_term)

  defp query_open_aq(cached_locations, search_term) when length(cached_locations) < 10 do
    search_term
    |> @open_aq.get_locations()
    |> start_measurement_task()
  end

  defp query_open_aq(cached_locations, search_term) do
    {:ok, _pid} =
      Task.Supervisor.start_child(TaskSupervisor, fn ->
        @open_aq.get_locations(search_term)
      end)

    start_measurement_task(cached_locations)
  end

  defp query_open_aq([], lat, lon), do: @open_aq.get_locations(lat, lon)

  defp query_open_aq(cached_locations, lat, lon) when length(cached_locations) < 10 do
    lat
    |> @open_aq.get_locations(lon)
    |> start_measurement_task()
  end

  defp query_open_aq(cached_locations, lat, lon) do
    {:ok, _pid} =
      Task.Supervisor.start_child(TaskSupervisor, fn ->
        @open_aq.get_locations(lat, lon)
      end)

    start_measurement_task(cached_locations)
  end

  defp start_measurement_task(locations) do
    {:ok, _pid} =
      Task.Supervisor.start_child(TaskSupervisor, fn ->
        Enum.map(locations, fn location ->
          @open_aq.get_latest_measurements(location.id)
        end)
      end)

    locations
  end

  def get_latest_measurements(location_id, lat, lon) do
    lat
    |> Google.Geocoding.find_location_country_code(lon)
    |> (&Enum.member?(EEA.country_codes(), &1)).()
    |> case do
      true -> []
      false -> @open_aq.get_latest_measurements(location_id)
    end
  end
end
