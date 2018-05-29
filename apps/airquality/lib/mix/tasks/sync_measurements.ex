defmodule Mix.Tasks.SyncMeasurements do
  use Mix.Task

  alias Airquality.{Sources.OpenAQ, Data}

  @shortdoc "Syncs measurements for all locations in db"

  def run(_args) do
    Mix.Task.run("app.start")

    Data.all_locations()
    |> Enum.each(fn location ->
      OpenAQ.get_latest_measurements(location.id)
    end)
  end
end
