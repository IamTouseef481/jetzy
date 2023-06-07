defmodule JetzySchema.Types.System.Event.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.System.Event.Ecto.UniversalReference
end
