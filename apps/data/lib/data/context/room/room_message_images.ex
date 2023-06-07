defmodule Data.Context.RoomMessageImages do
    import Ecto.Query, warn: false

    alias Data.Repo
#    alias Data.Context
    alias Data.Schema.RoomMessageImage

    @spec preload_all(RoomMessageImage.t()) :: RoomMessageImage.t()
    def preload_all(data), do: Repo.preload(data, [])

  end
