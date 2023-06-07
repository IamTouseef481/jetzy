defmodule Data.Context.Careers do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.Career

  @spec preload_all(Career.t()) :: Career.t()
  def preload_all(data), do: Repo.preload(data, [])

end
