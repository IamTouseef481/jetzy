defmodule JetzySchema.Types.Reward.Tier.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Reward.Tier.Ecto.UniversalReference
end
