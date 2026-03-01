defmodule ColorPickerLive.Seeder do
  alias ColorPickerLive.Repo

  def seed_color_pickers do
    pickers = for _ <- 1..1_000_000 do
      %{
        color: "#FFFFFF",
        inserted_at: NaiveDateTime.utc_now(),
        updated_at: NaiveDateTime.utc_now()
      }
    end

    # Insert in batches
    Enum.chunk_every(pickers, 10_000)
    |> Enum.each(fn batch ->
      IO.puts("Inserting a batch of 10,000 pickers")
      Repo.insert_all("pickers", batch)
    end)
  end
end
