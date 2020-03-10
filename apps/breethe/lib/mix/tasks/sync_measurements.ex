defmodule Mix.Tasks.SyncMeasurements do
  use Mix.Task

  alias Breethe.{Sources.EEA, Data}

  @shortdoc "Refreshes European data"

  def run(_args) do
    Mix.Task.run("app.start")
  end
end
