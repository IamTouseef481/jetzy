defmodule Data.Context.Subscriptions do
  
  def by_handle(handle) do
    Data.Repo.get_by(Data.Schema.Subscription, handle: handle)
  end
end