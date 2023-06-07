defmodule JetzySchema.Types.VersionedAddress.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.VersionedAddress.Ecto.UniversalReference
end
