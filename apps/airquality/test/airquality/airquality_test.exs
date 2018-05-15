defmodule AirqualityTest do
  use Airquality.DataCase

  import Mox
  import Airquality.Factory

  alias Airquality.Sources.OpenAQMock, as: Mock

  setup :set_mox_global
  setup :verify_on_exit!

  describe "search_locations(search_term):" do
    test "returns locations after awaiting on async call to API (no matching records in db)" do
      location = build(:location)

      Mock
      |> expect(:get_locations, fn _search_term -> Mock.get_locations(0.0, 0.0) end)
      |> expect(:get_locations, fn _lat, _lon -> [location] end)

      assert [location] == Airquality.search_locations("pdx")
    end

    test "returns matching locations from db and starts a Task to retreive new data in the background" do
      location = insert(:location)

      Mock
      |> expect(:get_locations, fn _search_term -> Mock.get_locations(0.0, 0.0) end)
      |> expect(:get_locations, fn _lat, _lon -> [location | insert_pair(:location)] end)

      {locations, pid} = Airquality.search_locations(location.identifier)
      ref = Process.monitor(pid)

      assert locations == [location]
      assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
    end
  end

  describe "search_locations(lat, lon):" do
    test "returns locations after awaiting on async call to API (no matching records in db)" do
      location = build(:location)

      Mock
      |> expect(:get_locations, fn _search_term -> Mock.get_locations(0.0, 0.0) end)
      |> expect(:get_locations, fn _lat, _lon -> [location] end)

      assert [location] == Airquality.search_locations("pdx")
    end

    test "returns matching locations from db and starts a Task to retreive new data in the background" do
      location = insert(:location)

      Mock
      |> expect(:get_locations, fn _search_term -> Mock.get_locations(0.0, 0.0) end)
      |> expect(:get_locations, fn _lat, _lon -> [location | insert_pair(:location)] end)

      {locations, pid} = Airquality.search_locations(location.identifier)
      ref = Process.monitor(pid)

      assert locations == [location]
      assert_receive {:DOWN, ^ref, :process, _, :normal}, 500
    end
  end
end
