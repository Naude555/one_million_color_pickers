defmodule ColorPickerLive.PickersTest do
  use ColorPickerLive.DataCase

  alias ColorPickerLive.Pickers

  describe "pickers" do
    alias ColorPickerLive.Pickers.Picker

    import ColorPickerLive.PickersFixtures

    @invalid_attrs %{color: nil}

    test "list_pickers/0 returns all pickers" do
      picker = picker_fixture()
      assert Pickers.list_pickers() == [picker]
    end

    test "get_picker!/1 returns the picker with given id" do
      picker = picker_fixture()
      assert Pickers.get_picker!(picker.id) == picker
    end

    test "create_picker/1 with valid data creates a picker" do
      valid_attrs = %{color: "some color"}

      assert {:ok, %Picker{} = picker} = Pickers.create_picker(valid_attrs)
      assert picker.color == "some color"
    end

    test "create_picker/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pickers.create_picker(@invalid_attrs)
    end

    test "update_picker/2 with valid data updates the picker" do
      picker = picker_fixture()
      update_attrs = %{color: "some updated color"}

      assert {:ok, %Picker{} = picker} = Pickers.update_picker(picker, update_attrs)
      assert picker.color == "some updated color"
    end

    test "update_picker/2 with invalid data returns error changeset" do
      picker = picker_fixture()
      assert {:error, %Ecto.Changeset{}} = Pickers.update_picker(picker, @invalid_attrs)
      assert picker == Pickers.get_picker!(picker.id)
    end

    test "delete_picker/1 deletes the picker" do
      picker = picker_fixture()
      assert {:ok, %Picker{}} = Pickers.delete_picker(picker)
      assert_raise Ecto.NoResultsError, fn -> Pickers.get_picker!(picker.id) end
    end

    test "change_picker/1 returns a picker changeset" do
      picker = picker_fixture()
      assert %Ecto.Changeset{} = Pickers.change_picker(picker)
    end
  end

  describe "pickers" do
    alias ColorPickerLive.Pickers.Picker

    import ColorPickerLive.PickersFixtures

    @invalid_attrs %{}

    test "list_pickers/0 returns all pickers" do
      picker = picker_fixture()
      assert Pickers.list_pickers() == [picker]
    end

    test "get_picker!/1 returns the picker with given id" do
      picker = picker_fixture()
      assert Pickers.get_picker!(picker.id) == picker
    end

    test "create_picker/1 with valid data creates a picker" do
      valid_attrs = %{}

      assert {:ok, %Picker{} = picker} = Pickers.create_picker(valid_attrs)
    end

    test "create_picker/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Pickers.create_picker(@invalid_attrs)
    end

    test "update_picker/2 with valid data updates the picker" do
      picker = picker_fixture()
      update_attrs = %{}

      assert {:ok, %Picker{} = picker} = Pickers.update_picker(picker, update_attrs)
    end

    test "update_picker/2 with invalid data returns error changeset" do
      picker = picker_fixture()
      assert {:error, %Ecto.Changeset{}} = Pickers.update_picker(picker, @invalid_attrs)
      assert picker == Pickers.get_picker!(picker.id)
    end

    test "delete_picker/1 deletes the picker" do
      picker = picker_fixture()
      assert {:ok, %Picker{}} = Pickers.delete_picker(picker)
      assert_raise Ecto.NoResultsError, fn -> Pickers.get_picker!(picker.id) end
    end

    test "change_picker/1 returns a picker changeset" do
      picker = picker_fixture()
      assert %Ecto.Changeset{} = Pickers.change_picker(picker)
    end
  end
end
