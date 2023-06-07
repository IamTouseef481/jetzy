defmodule JetzySchema.Types.Business.Restaurant.Location.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Business.Restaurant.Location.Ecto.UniversalReference
end
