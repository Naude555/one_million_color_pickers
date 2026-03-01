defmodule ColorPickerLive.Repo do
  use Ecto.Repo,
    otp_app: :color_picker_live,
    adapter: Ecto.Adapters.Postgres
end
