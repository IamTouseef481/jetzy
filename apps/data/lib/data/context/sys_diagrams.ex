defmodule Data.Context.SysDiagrams do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.SysDiagram

  @spec preload_all(SysDiagram.t()) :: SysDiagram.t()
  def preload_all(data), do: Repo.preload(data, [])

end
