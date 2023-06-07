defmodule JetzySchema.Types.VersionedDeal.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.VersionedDeal.Ecto.UniversalReference
end
