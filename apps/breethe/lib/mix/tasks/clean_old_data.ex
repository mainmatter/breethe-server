defmodule Mix.Tasks.CleanOldData do
  use Mix.Task

  alias Breethe.Data

  @shortdoc "Cleans up old European data"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")

    Data.delete_old_data(3)

    Mix.shell().info("Dropped old data successfully")
  end
end
