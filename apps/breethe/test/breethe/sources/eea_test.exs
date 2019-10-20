defmodule Breethe.Sources.EEATest do
  use Breethe.DataCase

  import Breethe.Factory

  alias Breethe.Sources.EEA

  setup do
    bypass = Bypass.open()

    Application.put_env(
      :breethe,
      :eea_endpoint,
      "http://localhost:#{bypass.port}/eea"
    )

    {:ok, bypass: bypass}
  end

  describe "download data:" do
    test "for a list of countries and params" do
      assert false
    end
  end
end
