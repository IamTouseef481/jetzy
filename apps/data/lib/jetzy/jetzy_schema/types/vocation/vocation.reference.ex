defmodule JetzySchema.Types.Vocation.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Vocation.Ecto.UniversalReference
end
