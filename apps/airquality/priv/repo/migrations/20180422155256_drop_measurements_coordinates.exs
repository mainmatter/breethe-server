defmodule Airquality.Repo.Migrations.DropMeasurementsCoordinates do
  use Ecto.Migration

  def change do
    alter table(:measurements) do
      remove :coordinates
    end
  end
end
