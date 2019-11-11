defmodule Breethe.Sources do
  @moduledoc """
    This module checks location of query. 
    If in Europe, exits as data should already be in DB. 
    If not in Europe, initiates search through OpenAQ
  """

  defmodule Behaviour do
    @callback get_locations(search_term :: String.t()) :: [%Breethe.Data.Location{}]
    @callback get_locations(lat :: number, lon :: number) :: [%Breethe.Data.Location{}]
    @callback get_latest_measurements(location_id :: integer | String.t()) :: [
                %Breethe.Data.Measurement{}
              ]
  end

  def get_locations(search_term) do
  end

  def get_locations(lat, lon) do
  end

  def get_latest_measurements(location_id) do
  end
end
