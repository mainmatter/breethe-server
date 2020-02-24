defmodule Breethe.Sources do
  @moduledoc """
    This module checks location of query. 
    If in Europe, exits as data should already be in DB. 
    If not in Europe, initiates search through OpenAQ
  """

  alias __MODULE__.{Google, OpenAQ, EEA}

  defmodule Behaviour do
    @callback get_locations(search_term :: String.t()) :: [%Breethe.Data.Location{}]
    @callback get_locations(lat :: number, lon :: number) :: [%Breethe.Data.Location{}]
    @callback get_latest_measurements(
                location_id :: integer | String.t(),
                lat :: number,
                lon :: number
              ) :: [
                %Breethe.Data.Measurement{}
              ]
  end

  # @spec get_data([%Breethe.Data.Location{}], String.t()) :: [%Breethe.Data.Location{}]
  def get_data(locations, search_term) do
    search_term
    |> Google.Geocoding.find_location_country_code()
    |> (&Enum.member?(EEA.country_codes(), &1)).()
    |> case do
      true -> locations
      false -> query_open_aq(locations, search_term)
    end
  end

  def get_data(locations, lat, lon) do
    lat
    |> Google.Geocoding.find_location_country_code(lon)
    |> (&Enum.member?(EEA.country_codes(), &1)).()
    |> case do
      true -> locations
      false -> query_open_aq(locations, lat, lon)
    end
  end

  # @spec query_open_aq([%Breethe.Data.Location{}], String.t()) :: [%Breethe.Data.Location{}]
  defp query_open_aq([], search_term), do: OpenAQ.get_locations(search_term)

  defp query_open_aq(locations, search_term) when length(locations) < 10 do
    search_term
    |> OpenAQ.get_locations()
    |> start_measurement_task()
  end

  defp query_open_aq(locations, search_term) do
    {:ok, _pid} =
      Task.Supervisor.start_child(TaskSupervisor, fn ->
        OpenAQ.get_locations(search_term)
      end)

    start_measurement_task(locations)
  end

  defp query_open_aq([], lat, lon), do: OpenAQ.get_locations(lat, lon)

  defp query_open_aq(locations, lat, lon) when length(locations) < 10 do
    lat
    |> OpenAQ.get_locations(lon)
    |> start_measurement_task()
  end

  defp query_open_aq(locations, lat, lon) do
    {:ok, _pid} =
      Task.Supervisor.start_child(TaskSupervisor, fn ->
        OpenAQ.get_locations(lat, lon)
      end)

    start_measurement_task(locations)
  end

  defp start_measurement_task(locations) do
    {:ok, _pid} =
      Task.Supervisor.start_child(TaskSupervisor, fn ->
        Enum.map(locations, fn location ->
          OpenAQ.get_latest_measurements(location.id)
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
      false -> OpenAQ.get_latest_measurements(location_id)
    end
  end
end
