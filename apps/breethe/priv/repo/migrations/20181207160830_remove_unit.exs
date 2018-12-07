defmodule Breethe.Repo.Migrations.RemoveUnit do
  use Ecto.Migration

  def change do
    alter table(:measurements) do
      remove :unit
    end
  end
end
