defmodule Mix.Tasks.SyncData do
  use Mix.Task

  alias Breethe.Sources.EEA

  @shortdoc "Refreshes European data"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")
    EEA.get_data()
  end
end
