defmodule Breethe.Repo.Migrations.AddLocationSource do
  use Ecto.Migration

  def change do
    SourceEnum.create_type

    alter table(:locations) do
      add :source, :source
    end
  end
end
