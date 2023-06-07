defmodule JetzySchema.Types.VersionedString.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.VersionedString.Ecto.UniversalReference
end
