defmodule Data.Context.Items do
  
  def by_handle(handle) do
    Data.Repo.get_by(Data.Schema.Item, handle: handle)
  end
end