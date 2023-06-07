defmodule JetzySchema.Types.Business.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Business.Ecto.UniversalReference
end
