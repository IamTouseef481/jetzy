defmodule JetzySchema.Types.VersionedImageString.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.VersionedImageString.Ecto.UniversalReference
end
