defmodule Airquality.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :identifier, :string
      add :city, :string
      add :country, :string
      add :last_updated, :utc_datetime
      add :available_parameters, {:array, :parameter}
      add :coordinates, :geometry

      timestamps()
    end
  end
end
