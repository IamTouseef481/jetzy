defmodule JetzySchema.Types.User.Credential.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.User.Credential.Ecto.UniversalReference
end
