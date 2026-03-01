defmodule ColorPickerLive.Pickers.Picker do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pickers" do
    field :color, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(picker, attrs) do
    picker
    |> cast(attrs, [:color])
    |> validate_required([:color])
  end
end
