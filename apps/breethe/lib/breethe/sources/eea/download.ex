defmodule Breethe.Sources.EEA.Download do
  def get_latest({country, pollutant}) do
    url = "#{Application.get_env(:breethe, :eea_endpoint)}/#{country}_#{pollutant}.csv"

    {:ok, response} = HTTPoison.get(url)
    response.body
  end
end
