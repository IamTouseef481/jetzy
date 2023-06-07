defmodule JetzySchema.Types.Location.Country.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Location.Country.Ecto.UniversalReference
end
