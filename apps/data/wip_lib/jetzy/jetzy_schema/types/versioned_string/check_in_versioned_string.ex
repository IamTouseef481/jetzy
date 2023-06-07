defmodule JetzySchema.Types.CheckInVersionedString.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.CheckInVersionedString.Ecto.UniversalReference
end
