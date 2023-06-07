defmodule JetzySchema.Types.Device.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Device.Ecto.UniversalReference
end
