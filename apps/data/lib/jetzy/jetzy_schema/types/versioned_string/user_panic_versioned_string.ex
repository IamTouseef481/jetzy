defmodule JetzySchema.Types.UserPanicVersionedString.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.UserPanicVersionedString.Ecto.UniversalReference
end
