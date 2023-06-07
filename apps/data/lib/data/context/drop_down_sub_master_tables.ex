defmodule Data.Context.DropDownSubMasterTables do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.DropDownSubMasterTable

  @spec preload_all(DropDownSubMasterTable.t()) :: DropDownSubMasterTable.t()
  def preload_all(data), do: Repo.preload(data, [:master, :created_by, :updated_by, ])

end
