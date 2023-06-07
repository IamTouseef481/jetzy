defmodule JetzySchema.Types.LocationVersionedString.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.LocationVersionedString.Ecto.UniversalReference
end
