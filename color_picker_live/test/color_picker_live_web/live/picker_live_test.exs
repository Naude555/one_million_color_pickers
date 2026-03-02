defmodule ColorPickerLiveWeb.PickerLiveTest do
  use ColorPickerLiveWeb.ConnCase

  import Phoenix.LiveViewTest
  import ColorPickerLive.PickersFixtures

  test "scroll events update URL page without prev/next buttons", %{conn: conn} do
    Enum.each(1..12, fn index ->
      picker_fixture(%{color: "#00000#{rem(index, 10)}"})
    end)

    {:ok, view, html} = live(conn, ~p"/color_pickers?page=2&per_page=2")

    assert html =~ "One Million Color Pickers"
    assert html =~ "Current page"
    assert has_element?(view, "#color-picker-container")
    refute html =~ "Next →"
    refute html =~ "← Previous"

    render_hook(view, "load-more-down", %{})
    assert_patch(view, ~p"/color_pickers?page=3&per_page=2&sort_by=id&sort_order=asc")

    render_hook(view, "load-more-up", %{})
    assert_patch(view, ~p"/color_pickers?page=2&per_page=2&sort_by=id&sort_order=asc")
  end

  test "broadcast updates visible picker colors", %{conn: conn} do
    picker = picker_fixture(%{color: "#000000"})

    {:ok, view, _html} = live(conn, ~p"/color_pickers?page=1&per_page=20")

    assert has_element?(view, "button[phx-value-id='#{picker.id}']")

    ColorPickerLive.Pickers.update_picker(picker, %{color: "#abcdef"})

    assert render(view) =~ "#abcdef"
  end

  test "changing a color keeps the picker in place", %{conn: conn} do
    pickers =
      Enum.map(1..6, fn index ->
        picker_fixture(%{color: "#11111#{rem(index, 10)}"})
      end)

    target_picker = Enum.at(pickers, 2)

    {:ok, view, _html} = live(conn, ~p"/color_pickers?page=1&per_page=6")

    before_ids = visible_picker_ids(render(view))

    assert before_ids == Enum.map(pickers, & &1.id)

    view
    |> element("button[phx-value-id='#{target_picker.id}']")
    |> render_click()

    after_ids = visible_picker_ids(render(view))

    assert after_ids == before_ids
  end

  defp visible_picker_ids(html) do
    Regex.scan(~r/phx-value-id=['\"](\d+)['\"]/, html, capture: :all_but_first)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
  end
end
