defmodule Breethe.Repo.Migrations.CreateEnumTypes do
  use Ecto.Migration

  def up do
    ParameterEnum.create_type
  end

  def down do
    ParameterEnum.drop_type
    UnitEnum.drop_type
  end
end
