defmodule JetzySchema.Types.Location.City.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Location.City.Ecto.UniversalReference
end
