defmodule BreetheTest do
  use Breethe.DataCase

  import Mox
  import Breethe.Factory

  alias Breethe.TaskSupervisor

  setup :set_mox_global
  setup :verify_on_exit!

  describe "get_location(location_id)" do
  end

  describe "search_locations(search_term):" do
  end

  describe "search_locations(lat, lon):" do
  end

  describe "search_measurements(location_id):" do
  end

  defp assert_background_tasks_started() do
    TaskSupervisor
    |> Task.Supervisor.children()
    |> Enum.all?(fn task ->
      ref = Process.monitor(task)
      assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
    end)
  end

  defp stop_background_tasks() do
    TaskSupervisor
    |> Task.Supervisor.children()
    |> Enum.each(fn task ->
      Task.Supervisor.terminate_child(TaskSupervisor, task)
    end)
  end
end
