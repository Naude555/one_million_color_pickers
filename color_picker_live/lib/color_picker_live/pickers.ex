defmodule ColorPickerLive.Pickers do
  @moduledoc """
  The Pickers context.
  """

  import Ecto.Query, warn: false
  alias ColorPickerLive.Pickers.Picker
  alias ColorPickerLive.Repo

  @topic inspect(__MODULE__)
  @pubsub ColorPickerLive.PubSub

  def subscribe do
    Phoenix.PubSub.subscribe(@pubsub, @topic)
  end

  def broadcast({:ok, picker}, tag) do
    Phoenix.PubSub.broadcast(@pubsub, @topic, {tag, picker})
    {:ok, picker}
  end

  def broadcast({:error, _changeset}, _tag), do: :error

  @doc """
  Returns the list of pickers.

  ## Examples

      iex> list_pickers()
      [%Picker{}, ...]

  """
  def list_pickers do
    Repo.all(from(p in Picker, order_by: [asc: p.id]))
  end

  @doc """
  Returns a list of pickers based on the given `options`.

  Example options:

  %{sort_by: :id, sort_order: :asc, page: 2, per_page: 5}
  """
  def list_pickers(options) when is_map(options) do
    from(Picker)
    |> sort(options)
    |> paginate(options)
    |> select([p], %{id: p.id, color: p.color})
    |> Repo.all()
  end

  def count_pickers do
    Repo.aggregate(Picker, :count, :id)
  end

  defp sort(query, %{sort_by: sort_by, sort_order: sort_order}) do
    order_by(query, {^sort_order, ^sort_by})
  end

  defp sort(query, _options), do: query

  defp paginate(query, %{page: page, per_page: per_page}) do
    offset = max((page - 1) * per_page, 0)

    query
    |> limit(^per_page)
    |> offset(^offset)
  end

  @doc """
  Gets a single picker.

  Raises `Ecto.NoResultsError` if the Picker does not exist.

  ## Examples

      iex> get_picker!(123)
      %Picker{}

      iex> get_picker!(456)
      ** (Ecto.NoResultsError)

  """
  def get_picker!(id), do: Repo.get!(Picker, id)

  @doc """
  Creates a picker.

  ## Examples

      iex> create_picker(%{field: value})
      {:ok, %Picker{}}

      iex> create_picker(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_picker(attrs \\ %{}) do
    %Picker{}
    |> Picker.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a picker.

  ## Examples

      iex> update_picker(picker, %{field: new_value})
      {:ok, %Picker{}}

      iex> update_picker(picker, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_picker(%Picker{} = picker, attrs) do
    picker
    |> Picker.changeset(attrs)
    |> Repo.update()
    |> broadcast(:color_update)
  end

  @doc """
  Deletes a picker.

  ## Examples

      iex> delete_picker(picker)
      {:ok, %Picker{}}

      iex> delete_picker(picker)
      {:error, %Ecto.Changeset{}}

  """
  def delete_picker(%Picker{} = picker) do
    Repo.delete(picker)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking picker changes.

  ## Examples

      iex> change_picker(picker)
      %Ecto.Changeset{data: %Picker{}}

  """
  def change_picker(%Picker{} = picker, attrs \\ %{}) do
    Picker.changeset(picker, attrs)
  end
end
