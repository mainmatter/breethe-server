defmodule Airquality.Factory do
  use ExMachina.Ecto, repo: Airquality.Repo

  def location_factory do
    %Airquality.Data.Location{}
  end
end
