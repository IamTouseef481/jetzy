defmodule Data.Context.DropDownMasterTables do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.DropDownMasterTable

  @spec preload_all(DropDownMasterTable.t()) :: DropDownMasterTable.t()
  def preload_all(data), do: Repo.preload(data, [])

end
