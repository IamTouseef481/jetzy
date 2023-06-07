defmodule JetzySchema.Types.UserBioVersionedString.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.UserBioVersionedString.Ecto.UniversalReference
end
