defmodule Data.Context.Features do
  
  def by_handle(handle) do
    Data.Repo.get_by(Data.Schema.Feature, handle: handle)
  end
end