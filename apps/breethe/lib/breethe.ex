defmodule Breethe do
  @moduledoc """
  Breethe keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias __MODULE__.Data

  @behaviour Breethe.Behaviour
  @geocoding_api Application.get_env(:breethe, :google_api)

  defmodule Behaviour do
    @callback get_location(location_id :: integer) :: %Breethe.Data.Location{}
    @callback search_locations(search_term :: String.t()) :: [%Breethe.Data.Location{}]
    @callback search_locations(lat :: number, lon :: number) :: [%Breethe.Data.Location{}]
    @callback search_measurements(location_id :: integer | String.t()) :: [
                %Breethe.Data.Measurement{}
              ]
  end

  def get_location(location_id), do: Data.get_location(location_id)

  def search_locations(search_term) do
    case @geocoding_api.find_location(search_term) do
      [lat, lon] -> Data.find_locations(lat, lon)
      [] -> []
    end
  end

  def search_locations(lat, lon), do: Data.find_locations(lat, lon)

  def search_measurements(location_id), do: Data.find_measurements(location_id)
end
