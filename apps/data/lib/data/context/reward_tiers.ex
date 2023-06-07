defmodule Data.Context.RewardTiers do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.RewardTier

  @spec preload_all(RewardTier.t()) :: RewardTier.t()
  def preload_all(data), do: Repo.preload(data, [])

end
