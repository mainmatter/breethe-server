defmodule Breethe.Sources.Behaviour do
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