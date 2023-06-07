defmodule JetzySchema.Types.Business.Location.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Business.Location.Ecto.UniversalReference
end
