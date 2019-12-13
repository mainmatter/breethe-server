defmodule Breethe.Sources do
  @moduledoc """
    This module checks location of query. 
    If in Europe, exits as data should already be in DB. 
    If not in Europe, initiates search through OpenAQ
  """

  alias __MODULE__.{Google, OpenAQ, EEA}

  require IEx

  defmodule Behaviour do
    @callback get_locations(search_term :: String.t()) :: [%Breethe.Data.Location{}]
    @callback get_locations(lat :: number, lon :: number) :: [%Breethe.Data.Location{}]
    # @callback get_latest_measurements(location_id :: integer | String.t()) :: [
    #             %Breethe.Data.Measurement{}
    #           ]
  end

  def get_locations(search_term) do
    search_term
    |> Google.Geocoding.find_location_country_code()
    |> (&Enum.member?(EEA.country_codes(), &1)).()
    |> case do
      true -> []
      false -> OpenAQ.get_locations(search_term)
    end
  end

  def get_locations(lat, lon) do
    lat
    |> Google.Geocoding.find_location_country_code(lon)
    |> (&Enum.member?(EEA.country_codes(), &1)).()
    |> case do
      true -> []
      false -> OpenAQ.get_locations(lat, lon)
    end
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
