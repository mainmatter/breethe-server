defmodule Breethe.Sources.EEA.Download do
  def get_latest(country, param) do
    url = "#{Application.get_env(:breethe, :eea_endpoint)}/#{country}_#{param}.csv"

    HTTPoison.get(url)
  end
end
