defmodule Airquality.Repo.Migrations.CreateMeasurements do
  use Ecto.Migration

  def change do
    create table(:measurements) do
      add :parameter, :parameter
      add :location_id, references(:locations), null: false
      add :measured_id, :utc_datetime
      add :value, :float
      add :unit, :unit
      add :coordinates, :geometry

      timestamps()
    end
  end
end
