defmodule ColorPickerLiveWeb.ColorPickerLive do

  use ColorPickerLiveWeb, :live_view

  alias ColorPickerLive.Pickers

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Pickers.subscribe()
    end

    socket =
      socket
      |> assign(:page_title, "Color Pickers")
      |> assign(:is_loading, true)
      |> assign(:page, 1)
      |> assign(:scroll_position, :bottom)
      |> assign(:visible_pickers, []) # Initialize visible pickers

    IO.inspect(socket.assigns, label: "After mount")

    {:ok, socket}
  end

  def handle_params(params, _url, socket) do
    sort_by = valid_sort_by(params)
    sort_order = valid_sort_order(params)
    page = param_to_integer(params["page"], 1)
    per_page = param_to_integer(params["per_page"], 5000)

    options = %{sort_by: sort_by, sort_order: sort_order, page: page, per_page: per_page}

    pickers = Pickers.list_pickers(options)

    # Get the new pickers' IDs, avoiding duplicates in `visible_pickers`
    picker_ids = Enum.map(pickers, & &1.id)
    # Precompute the first and last IDs of visible_pickers
    visible_pickers = socket.assigns.visible_pickers

    visible_pickers =
      cond do
        visible_pickers == [] ->
          # If the list is empty, initialize with the new pickers
          picker_ids
        true ->
          # Default case: Merge and sort if the new pickers overlap
          (visible_pickers ++ picker_ids)
          |> Enum.uniq()
      end

    socket =
      socket
      |> assign(:is_loading, false)
      |> assign(:options, options)
      |> assign(:visible_pickers, visible_pickers)

    # Stream the pickers depending on scroll position
    socket =
      if socket.assigns.scroll_position == :top do
        IO.puts("Scroll to Top")
        pickers = Enum.reverse(pickers)
        stream(socket, :pickers, pickers, at: 0)
      else
        IO.puts("Scroll to Bottom")
        stream(socket, :pickers, pickers)
      end


    {:noreply, socket}
  end

  defp param_to_integer(nil, default), do: default

  defp param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} ->
        number

      :error ->
        default
    end
  end

  defp valid_sort_by(%{"sort_by" => sort_by})
       when sort_by in ~w(id color) do
    String.to_atom(sort_by)
  end

  defp valid_sort_by(_params), do: :id

  defp valid_sort_order(%{"sort_by" => sort_by})
       when sort_by in ~w(asc desc) do
    String.to_atom(sort_by)
  end

  defp valid_sort_order(_params), do: :asc


  def render(assigns) do
    ~H"""
    <div>
      <h1>Color Pickers</h1>
        <%= if @is_loading do %>
          <div class="flex justify-center items-center w-full h-full">
            <div class="loader"></div>
          </div>
        <% else %>
            <div id="color-picker-container"
            class="grid grid-cols-50-cols sm:grid-cols-10-cols md:grid-cols-25-cols lg:grid-cols-50-cols lx:grid-cols-100-cols 2lx:grid-cols-200-cols
               min-w-[20px] min-h-[20px] bg-light-gray"
            style="overflow-y: scroll; height: 90vh;"
            phx-update="stream"
            phx-hook="InfiniteScroll"
            phx_debounce= "300">
            <.picker :for={{dom_id, picker} <- @streams.pickers} dom_id={dom_id} picker={picker} />
          </div>
        <% end %>
    </div>
    """
  end


  def picker(assigns) do
    ~H"""
    <div class="color-picker" style={"background-color: #{ @picker.color }"} id={@dom_id}>
      <button phx-click="change_color" phx-value-id={ @picker.id } class="w-full h-full border-solid border-2 border-black">
        <%= @picker.id %>
      </button>
    </div>
    """
  end

  def handle_event("change_color", %{"id" => id}, socket) do
    picker = Pickers.get_picker!(id)

    new_color = random_hex_color()

    {:ok, _picker} = Pickers.update_picker(picker, %{color: new_color})

    {:noreply, socket}
  end

  def handle_event("load-more-down", _, socket) do
    IO.puts("Load More Down")

    page = socket.assigns.options.page
    per_page = socket.assigns.options.per_page
    visible_pickers = socket.assigns.visible_pickers

    socket =
      if page > 3 do
        remove_pickers = Enum.take(visible_pickers, per_page)
        updated_visible_pickers = update_visible_pickers(visible_pickers, per_page, :down)

        # Remove pickers from the stream
        socket =
          socket
          |> remove_pickers_from_stream(remove_pickers)
          |> assign(:visible_pickers, updated_visible_pickers)
      else
        socket
      end

    socket = assign(socket, :scroll_position, :down)
    {:noreply, navigate_to_page(socket, :down)}
  end

  def handle_event("load-more-up", _, socket) do
    IO.puts("Load More Up")

    page = socket.assigns.options.page
    per_page = socket.assigns.options.per_page
    visible_pickers = socket.assigns.visible_pickers

    # Default socket assignment
    socket =
      if page > 1 do
        remove_pickers = Enum.slice(visible_pickers, -per_page * 3, per_page * 3)
        updated_visible_pickers = update_visible_pickers(visible_pickers, per_page, :up)

        socket
        |> remove_pickers_from_stream(remove_pickers)
        |> assign(:visible_pickers, updated_visible_pickers)
      else
        socket
      end

    socket = assign(socket, :scroll_position, :top)
    {:noreply, navigate_to_page(socket, :up)}
  end



  defp navigate_to_page(socket, direction) do
    current_page = socket.assigns.options.page
    new_page = case direction do
      :up -> current_page - 1
      :down -> current_page + 1
    end

    goto_page(socket, new_page)
  end



  defp update_visible_pickers(visible_pickers, per_page, direction) do
    case direction do
      :up ->
        # Keep the first 3 pages worth of pickers
        Enum.take(visible_pickers, per_page * 3)
      :down ->
        # Keep the last 3 pages worth of pickers
        Enum.slice(visible_pickers, per_page * 3, per_page * 3)
    end
  end


  defp remove_pickers_from_stream(socket, remove_pickers) do
    IO.inspect(remove_pickers, label: "Remove Pickers")

    Enum.reduce(remove_pickers, socket, fn picker_id, acc_socket ->
      IO.inspect(picker_id, label: "Remove Picker")
      stream_delete(acc_socket, :pickers, fn picker -> IO.inspect(picker) end)
    end)
  end




  defp goto_page(socket, page) when page > 0 do
    params = %{socket.assigns.options | page: page}
    push_patch(socket, to: ~p"/color_pickers?#{params}")
  end

  defp goto_page(socket, _page), do: socket


  def handle_info({:color_update, picker}, socket) do
    visible_pickers = socket.assigns.visible_pickers

    # Check if the picker.id exists in the visible_pickers list
    if Enum.any?(visible_pickers, fn p -> p == picker.id end) do
      {:noreply, stream_insert(socket, :pickers, picker)}
    else
      {:noreply, socket}
    end
  end

  # # Binary search implementation for a sorted list
  # defp binary_search(list, target) do
  #   binary_search(list, target, 0, length(list) - 1)
  # end

  # defp binary_search(_list, _target, low, high) when low > high do
  #   false
  # end

  # defp binary_search(list, target, low, high) do
  #   mid = div(low + high, 2)
  #   mid_value = Enum.at(list, mid)

  #   cond do
  #     mid_value == target ->
  #       true

  #     mid_value < target ->
  #       binary_search(list, target, mid + 1, high)

  #     mid_value > target ->
  #       binary_search(list, target, low, mid - 1)
  #   end
  # end

  defp random_hex_color do
    "#" <> (:crypto.strong_rand_bytes(3) |> Base.encode16() |> String.downcase())
  end


end
