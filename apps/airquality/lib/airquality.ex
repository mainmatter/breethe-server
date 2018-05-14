defmodule Airquality do
  @moduledoc """
  Airquality keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @behaviour Airquality.Behaviour

  alias __MODULE__.{Data, Sources.OpenAQ}

  defmodule Behaviour do
    @callback search_locations(search_term :: String.t()) :: [%Airquality.Data.Location{}]
    @callback search_locations(lat :: number, lon :: number) :: [%Airquality.Data.Location{}]
  end

  def search_locations(search_term) do
    case Data.find_locations(search_term) do
      [] ->
        Task.async(fn ->
          OpenAQ.get_locations(search_term)
        end)
        |> Task.await()

      locations ->
        Task.start(fn ->
          OpenAQ.get_locations(search_term)
        end)

        locations
    end
  end

  def search_locations(lat, lon) do
    case Data.find_locations(lat, lon) do
      [] ->
        Task.async(fn ->
          OpenAQ.get_locations(lat, lon)
        end)
        |> Task.await

      locations ->
        Task.start(fn ->
          OpenAQ.get_locations(lat, lon)
        end)

        locations
    end
  end
end
