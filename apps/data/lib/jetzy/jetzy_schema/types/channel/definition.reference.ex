defmodule JetzySchema.Types.Channel.Definition.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Channel.Definition.Ecto.UniversalReference
end
