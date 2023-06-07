defmodule JetzySchema.Types.UserAboutVersionedString.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.UserAboutVersionedString.Ecto.UniversalReference
end
