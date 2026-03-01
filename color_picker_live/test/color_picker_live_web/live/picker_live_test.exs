defmodule ColorPickerLiveWeb.PickerLiveTest do
  use ColorPickerLiveWeb.ConnCase

  import Phoenix.LiveViewTest
  import ColorPickerLive.PickersFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_picker(_) do
    picker = picker_fixture()
    %{picker: picker}
  end

  describe "Index" do
    setup [:create_picker]

    test "lists all pickers", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/pickers")

      assert html =~ "Listing Pickers"
    end

    test "saves new picker", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/pickers")

      assert index_live |> element("a", "New Picker") |> render_click() =~
               "New Picker"

      assert_patch(index_live, ~p"/pickers/new")

      assert index_live
             |> form("#picker-form", picker: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#picker-form", picker: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/pickers")

      html = render(index_live)
      assert html =~ "Picker created successfully"
    end

    test "updates picker in listing", %{conn: conn, picker: picker} do
      {:ok, index_live, _html} = live(conn, ~p"/pickers")

      assert index_live |> element("#pickers-#{picker.id} a", "Edit") |> render_click() =~
               "Edit Picker"

      assert_patch(index_live, ~p"/pickers/#{picker}/edit")

      assert index_live
             |> form("#picker-form", picker: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#picker-form", picker: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/pickers")

      html = render(index_live)
      assert html =~ "Picker updated successfully"
    end

    test "deletes picker in listing", %{conn: conn, picker: picker} do
      {:ok, index_live, _html} = live(conn, ~p"/pickers")

      assert index_live |> element("#pickers-#{picker.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#pickers-#{picker.id}")
    end
  end

  describe "Show" do
    setup [:create_picker]

    test "displays picker", %{conn: conn, picker: picker} do
      {:ok, _show_live, html} = live(conn, ~p"/pickers/#{picker}")

      assert html =~ "Show Picker"
    end

    test "updates picker within modal", %{conn: conn, picker: picker} do
      {:ok, show_live, _html} = live(conn, ~p"/pickers/#{picker}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Picker"

      assert_patch(show_live, ~p"/pickers/#{picker}/show/edit")

      assert show_live
             |> form("#picker-form", picker: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#picker-form", picker: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/pickers/#{picker}")

      html = render(show_live)
      assert html =~ "Picker updated successfully"
    end
  end
end
