defmodule ColorPickerLiveWeb.ColorPickerLive do
  use ColorPickerLiveWeb, :live_view

  alias ColorPickerLive.Pickers

  @default_per_page 250
  @window_radius 3

  def mount(_params, _session, socket) do
    if connected?(socket), do: Pickers.subscribe()

    {:ok,
     socket
     |> assign(:page_title, "One Million Color Pickers")
     |> assign(:is_loading, true)
     |> assign(:visible_picker_ids, MapSet.new())
     |> assign(:pending_scroll_direction, :initial)
     |> assign(:options, %{sort_by: :id, sort_order: :asc, page: 1, per_page: @default_per_page})
     |> assign(:total_pickers, Pickers.count_pickers())}
  end

  def handle_params(params, _url, socket) do
    options = %{
      sort_by: valid_sort_by(params),
      sort_order: valid_sort_order(params),
      page: param_to_integer(params["page"], 1),
      per_page: param_to_integer(params["per_page"], @default_per_page)
    }

    options = clamp_page_options(options, socket.assigns.total_pickers)
    pickers = paged_window(options)
    direction = socket.assigns.pending_scroll_direction

    {:noreply,
     socket
     |> assign(:is_loading, false)
     |> assign(:options, options)
     |> assign(:pending_scroll_direction, :idle)
     |> assign(:visible_picker_ids, MapSet.new(Enum.map(pickers, & &1.id)))
     |> push_event("page-loaded", %{page: options.page, direction: direction})
     |> stream(:pickers, pickers, reset: true)}
  end

  def handle_event("change_color", %{"id" => id}, socket) do
    picker = Pickers.get_picker!(id)
    {:ok, _picker} = Pickers.update_picker(picker, %{color: random_hex_color()})

    {:noreply, socket}
  end

  def handle_event("load-more-down", _, socket), do: {:noreply, navigate_to_page(socket, :down)}
  def handle_event("load-more-up", _, socket), do: {:noreply, navigate_to_page(socket, :up)}

  def handle_info({:color_update, picker}, socket) do
    if MapSet.member?(socket.assigns.visible_picker_ids, picker.id) do
      {:noreply, stream_insert(socket, :pickers, picker)}
    else
      {:noreply, socket}
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-screen-2xl px-4 py-4">
      <div class="mb-4 rounded-xl border border-zinc-200 bg-white p-4 shadow-sm">
        <h1 class="text-2xl font-bold text-zinc-900">One Million Color Pickers</h1>
        <p class="mt-1 text-sm text-zinc-600">
          Scroll continuously to browse pickers. Page swaps happen automatically and the URL tracks your position.
        </p>

        <div class="mt-3 flex flex-wrap items-center gap-2 text-sm">
          <span class="rounded-md bg-zinc-100 px-3 py-1.5 text-zinc-700">
            Current page <strong><%= @options.page %></strong>
          </span>
          <span class="rounded-md bg-zinc-100 px-3 py-1.5 text-zinc-700">
            <%= @options.per_page %> per page
          </span>
          <span class="rounded-md bg-zinc-100 px-3 py-1.5 text-zinc-700">
            Updates sync live across all open screens
          </span>
        </div>
      </div>

      <%= if @is_loading do %>
        <div class="flex h-[70vh] items-center justify-center">
          <div class="loader"></div>
        </div>
      <% else %>
        <div
          id="color-picker-container"
          class="h-[calc(100vh-13rem)] overflow-y-auto rounded-xl border border-zinc-200 bg-zinc-50 p-3"
          phx-hook="InfiniteScroll"
        >
          <div id="pickers-grid" class="grid grid-cols-[repeat(auto-fill,minmax(72px,1fr))] gap-2" phx-update="stream">
            <.picker :for={{dom_id, picker} <- @streams.pickers} dom_id={dom_id} picker={picker} />
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def picker(assigns) do
    ~H"""
    <button
      id={@dom_id}
      phx-click="change_color"
      phx-value-id={@picker.id}
      class="group relative aspect-square w-full overflow-hidden rounded-lg border border-zinc-800/20 shadow-sm transition hover:scale-[1.02] focus:outline-none focus:ring-2 focus:ring-zinc-900/40"
      style={"background-color: #{@picker.color}"}
      title={"Picker ##{@picker.id}"}
    >
      <span class="absolute inset-x-0 bottom-0 bg-black/45 px-1 py-0.5 text-[11px] font-medium text-white opacity-0 transition group-hover:opacity-100">
        #<%= @picker.id %>
      </span>
    </button>
    """
  end

  defp paged_window(%{page: page} = options) do
    (page - @window_radius)..(page + @window_radius)
    |> Enum.filter(&(&1 > 0))
    |> Enum.flat_map(fn page_number ->
      Pickers.list_pickers(%{options | page: page_number})
    end)
  end

  defp navigate_to_page(socket, direction) do
    current_page = socket.assigns.options.page

    new_page =
      case direction do
        :up -> current_page - 1
        :down -> current_page + 1
      end

    goto_page(assign(socket, :pending_scroll_direction, direction), new_page)
  end

  defp goto_page(socket, page) when page > 0 do
    params = clamp_page_options(%{socket.assigns.options | page: page}, socket.assigns.total_pickers)
    push_patch(socket, to: page_path(params, params.page))
  end

  defp goto_page(socket, _page), do: socket

  defp page_path(options, page) do
    ~p"/color_pickers?#{%{options | page: page}}"
  end

  defp clamp_page_options(options, total_pickers) do
    max_page = max(div(total_pickers + options.per_page - 1, options.per_page), 1)
    %{options | page: min(max(options.page, 1), max_page)}
  end

  defp valid_sort_by(%{"sort_by" => sort_by}) when sort_by in ~w(id color), do: String.to_atom(sort_by)
  defp valid_sort_by(_params), do: :id

  defp valid_sort_order(%{"sort_order" => sort_order}) when sort_order in ~w(asc desc),
    do: String.to_atom(sort_order)

  defp valid_sort_order(_params), do: :asc

  defp param_to_integer(nil, default), do: default

  defp param_to_integer(param, default) do
    case Integer.parse(param) do
      {number, _} when number > 0 -> number
      _ -> default
    end
  end

  defp random_hex_color do
    "#" <> (:crypto.strong_rand_bytes(3) |> Base.encode16() |> String.downcase())
  end
end
