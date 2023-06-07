defmodule Data.Context.Statuses do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.Status

  @spec preload_all(Status.t()) :: Status.t()
  def preload_all(data), do: Repo.preload(data, [])

end
