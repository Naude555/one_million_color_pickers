defmodule ColorPickerLive.Repo.Migrations.CreatePickers do
  use Ecto.Migration

  def change do
    create table(:pickers) do
      add :color, :string, default: "#FFFFFF", null: false

      timestamps(type: :utc_datetime)
    end
  end
end
