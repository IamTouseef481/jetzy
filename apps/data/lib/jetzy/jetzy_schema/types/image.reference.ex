defmodule JetzySchema.Types.Image.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Image.Ecto.UniversalReference
end
