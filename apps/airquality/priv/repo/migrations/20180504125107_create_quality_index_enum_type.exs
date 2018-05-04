defmodule Airquality.Repo.Migrations.CreateQualityIndexEnumType do
  use Ecto.Migration

  def up do
    IndexEnum.create_type
  end

  def down do
    IndexEnum.drop_type
  end
end
