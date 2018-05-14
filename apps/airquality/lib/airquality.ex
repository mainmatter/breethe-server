defmodule Airquality do
  @moduledoc """
  Airquality keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  alias __MODULE__.{Data, Sources.OpenAQ}

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
end
