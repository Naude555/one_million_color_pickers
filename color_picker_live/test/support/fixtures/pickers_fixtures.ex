defmodule ColorPickerLive.PickersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ColorPickerLive.Pickers` context.
  """

  @doc """
  Generate a picker.
  """
  def picker_fixture(attrs \\ %{}) do
    {:ok, picker} =
      attrs
      |> Enum.into(%{color: "#112233"})
      |> ColorPickerLive.Pickers.create_picker()

    picker
  end
end
