defmodule Airquality.Repo.Migrations.AddQualityIndexToMeasurementsTable do
  use Ecto.Migration

  def change do
    alter table(:measurements) do
      add :quality_index, :quality_index
    end
  end
end
