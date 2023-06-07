defmodule JetzySchema.Types.VersionedLink.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.VersionedLink.Ecto.UniversalReference
end
