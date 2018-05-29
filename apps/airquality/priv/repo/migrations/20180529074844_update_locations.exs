defmodule Airquality.Repo.Migrations.UpdateLocations do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :label, :string
    end
  end
end
