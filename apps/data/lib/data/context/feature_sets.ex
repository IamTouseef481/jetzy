defmodule Data.Context.FeatureSets do
  
  def by_handle(handle) do
    Data.Repo.get_by(Data.Schema.FeatureSet, handle: handle)
  end
end