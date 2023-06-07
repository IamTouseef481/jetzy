defmodule JetzySchema.Types.Offer.Activity.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Offer.Activity.Ecto.UniversalReference
end
