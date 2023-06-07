defmodule JetzySchema.Types.UserVersionedString.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.UserVersionedString.Ecto.UniversalReference
end
