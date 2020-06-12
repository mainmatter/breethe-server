defmodule Breethe.Repo.Migrations.AddMeasurementTimeIndex do
  use Ecto.Migration

  def change do
    create index("measurements", [:measured_at])
  end
end
