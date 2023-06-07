defmodule Data.Context.JetzyTestSepts do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.JetzyTestSept

  @spec preload_all(JetzyTestSept.t()) :: JetzyTestSept.t()
  def preload_all(data), do: Repo.preload(data, [])

end
