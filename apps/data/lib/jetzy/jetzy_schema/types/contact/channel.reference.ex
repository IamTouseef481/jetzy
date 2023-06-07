defmodule JetzySchema.Types.Contact.Channel.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Contact.Channel.Ecto.UniversalReference
end
