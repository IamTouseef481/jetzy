defmodule Data.Context.Subscription.Groups do
  
  def by_handle(handle) do
    Data.Repo.get_by(Data.Schema.Subscription.Group, handle: handle)
  end
end