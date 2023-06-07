defmodule JetzySchema.Types.VersionedBusiness.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.VersionedBusiness.Ecto.UniversalReference
end
