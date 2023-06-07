defmodule JetzySchema.Types.VersionedNightLife.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.VersionedNightLife.Ecto.UniversalReference
end
