defmodule JetzySchema.Types.ModerationVersionedString.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.ModerationVersionedString.Ecto.UniversalReference
end
