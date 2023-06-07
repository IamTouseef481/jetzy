defmodule JetzySchema.Types.Location.State.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Location.State.Ecto.UniversalReference
end
