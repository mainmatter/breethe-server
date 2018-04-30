defmodule Airquality.Data do
  alias __MODULE__.{Location, Measurement}
  alias Airquality.Repo

  def get_location(id), do: Repo.get(Location, id)
end
