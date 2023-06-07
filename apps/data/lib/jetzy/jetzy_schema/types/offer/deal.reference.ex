defmodule JetzySchema.Types.Offer.Deal.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Offer.Deal.Ecto.UniversalReference
end
