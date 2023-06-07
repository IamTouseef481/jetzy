defmodule JetzySchema.Types.Interest.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Interest.Ecto.UniversalReference
end
