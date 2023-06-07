defmodule JetzySchema.Types.OperatingSystem.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.OperatingSystem.Ecto.UniversalReference
end
