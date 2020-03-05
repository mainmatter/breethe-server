defmodule Breethe.Repo.Migrations.AddLocationSource do
  use Ecto.Migration

  def change do
    alter table(:locations) do
      add :source, :string
    end
  end
end
