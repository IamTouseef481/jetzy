defmodule Data.Context.AdminTests do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.AdminTest

  @spec preload_all(AdminTest.t()) :: AdminTest.t()
  def preload_all(data), do: Repo.preload(data, [])

end
