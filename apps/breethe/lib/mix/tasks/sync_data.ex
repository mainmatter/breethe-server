defmodule Mix.Tasks.SyncData do
  use Mix.Task

  alias Breethe.Sources.EEA

  @shortdoc "Refreshes European data"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    failed_imports =
      EEA.get_data()
      |> Enum.flat_map(fn result -> [result] end)
      |> Enum.filter(&match?({:error, _}, &1))

    case length(failed_imports) do
      0 -> Mix.shell().info("Updated successfully")
      _ -> Mix.shell().error("Some updates failed")
    end
  end
end
