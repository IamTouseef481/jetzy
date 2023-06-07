defmodule JetzySchema.Types.PostVersionedString.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.PostVersionedString.Ecto.UniversalReference
end
