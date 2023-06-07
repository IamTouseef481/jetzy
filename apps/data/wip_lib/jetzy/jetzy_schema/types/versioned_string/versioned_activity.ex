defmodule JetzySchema.Types.VersionedActivity.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.VersionedActivity.Ecto.UniversalReference
end
