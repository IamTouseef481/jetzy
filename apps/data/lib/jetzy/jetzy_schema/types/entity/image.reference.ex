defmodule JetzySchema.Types.Entity.Image.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Entity.Image.Ecto.UniversalReference
end
