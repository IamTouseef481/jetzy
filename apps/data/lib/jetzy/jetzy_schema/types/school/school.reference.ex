defmodule JetzySchema.Types.School.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.School.Ecto.UniversalReference
end
