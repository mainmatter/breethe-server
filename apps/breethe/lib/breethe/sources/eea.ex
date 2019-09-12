defmodule Breethe.Sources.EEA do
  alias __MODULE__.{CSV, Download}

  def get_data(country, pollutant) do
    {country, pollutant}
    |> Download.download_file()
    |> CSV.process_data()
  end
end
