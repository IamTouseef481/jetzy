defmodule JetzySchema.Types.VersionedName.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.VersionedName.Ecto.UniversalReference
end
