defmodule JetzySchema.Types.Payment.Provider.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Payment.Provider.Ecto.UniversalReference
end
