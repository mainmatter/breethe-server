defmodule Breethe.SourcesTest do
  use Breethe.DataCase

  import Mox
  import Breethe.Factory

  alias Breethe.{Sources, TaskSupervisor}
  alias Breethe.Sources.{OpenAQMock, GoogleMock}

  require IEx

  setup :set_mox_global
  setup :verify_on_exit!

  describe "get_data(locations, search_term):" do
    test "no-op and returns locations if search_term is in the EEA" do
      search_term = "Munich"
      expect(GoogleMock, :find_location_country_code, fn ^search_term -> "DE" end)

      assert [] = Sources.get_data([], search_term)
    end

    test "returns OpenAQ locations if search_term isn't in the EEA and locations list is empty" do
      search_term = "Portland"

      expect(GoogleMock, :find_location_country_code, fn ^search_term -> "US" end)
      expect(OpenAQMock, :get_locations, fn ^search_term -> [] end)

      assert [] = Sources.get_data([], search_term)
    end

    test "returns OpenAQ locations if search_term isn't in the EEA and locations list is smaller than 10" do
      search_term = "Portland"

      cached_locations = [insert(:location)]
      open_aq_locations = build_list(3, :location)

      expect(GoogleMock, :find_location_country_code, fn ^search_term -> "US" end)
      expect(OpenAQMock, :get_locations, fn ^search_term -> open_aq_locations end)

      returned_locations = Sources.get_data(cached_locations, search_term)
      stop_background_tasks()

      assert open_aq_locations == returned_locations
    end

    test "returns OpenAQ locations and starts a background task for measurements" do
      search_term = "Portland"

      cached_locations = [insert(:location)]
      open_aq_locations = build_list(3, :location)

      stub(GoogleMock, :find_location_country_code, fn ^search_term -> "US" end)

      OpenAQMock
      |> stub(:get_locations, fn ^search_term -> open_aq_locations end)
      |> expect(:get_latest_measurements, length(open_aq_locations), fn _location_id -> [] end)

      returned_locations = Sources.get_data(cached_locations, "Portland")

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)

      assert open_aq_locations == returned_locations
    end

    test "no-op and returns cached_locations if search_term isn't in the EEA and locations list is larger than 10" do
      search_term = "Portland"

      cached_locations = insert_list(10, :location)
      open_aq_locations = build_list(2, :location)

      expect(GoogleMock, :find_location_country_code, fn ^search_term -> "US" end)

      OpenAQMock
      |> expect(:get_locations, fn ^search_term -> open_aq_locations end)
      |> expect(:get_latest_measurements, length(cached_locations), fn _location_id -> [] end)

      returned_locations = Sources.get_data(cached_locations, search_term)

      TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.all?(fn task ->
        ref = Process.monitor(task)
        assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
      end)

      assert cached_locations == returned_locations
    end
  end

  defp stop_background_tasks() do
    TaskSupervisor
    |> Task.Supervisor.children()
    |> Enum.each(fn task ->
      Task.Supervisor.terminate_child(TaskSupervisor, task)
    end)
  end
end
