defmodule JetzySchema.Types.Universal.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Noizu.DomainObject.UUID.UniversalReference.Type
end
