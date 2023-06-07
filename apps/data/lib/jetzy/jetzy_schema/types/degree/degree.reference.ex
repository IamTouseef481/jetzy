defmodule JetzySchema.Types.Degree.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Degree.Ecto.UniversalReference
end
