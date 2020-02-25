defmodule Breethe.SourcesTest do
  use Breethe.DataCase

  import Mox

  alias Breethe.Sources
  alias Breethe.Sources.{OpenAQMock, GoogleMock}

  setup :set_mox_global
  setup :verify_on_exit!

  describe "get_data(locations, search_term):" do
    test "no-op and returns locations if search term is in the EEA country list (EU)" do
      expect(GoogleMock, :find_location_country_code, fn _search_term -> "DE" end)

      assert Sources.get_data([], "Munich")
    end
  end
end
