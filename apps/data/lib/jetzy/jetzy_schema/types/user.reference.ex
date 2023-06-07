defmodule JetzySchema.Types.User.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.User.Ecto.UniversalReference
end
