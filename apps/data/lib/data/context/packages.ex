defmodule Data.Context.Packages do
  
  def by_handle(handle) do
    Data.Repo.get_by(Data.Schema.Package, handle: handle)
  end
end