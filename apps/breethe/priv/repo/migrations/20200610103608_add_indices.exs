defmodule Breethe.Repo.Migrations.AddIndices do
  use Ecto.Migration

  def change do
    create index("locations", [:label])
    create index("locations", [:coordinates])
    create index("measurements", [:location_id])
  end
end
