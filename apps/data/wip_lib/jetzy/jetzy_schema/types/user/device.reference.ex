defmodule JetzySchema.Types.User.Device.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.User.Device.Ecto.UniversalReference
end
