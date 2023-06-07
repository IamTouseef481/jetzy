defmodule JetzySchema.Types.Business.Restaurant.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Business.Restaurant.Ecto.UniversalReference
end
