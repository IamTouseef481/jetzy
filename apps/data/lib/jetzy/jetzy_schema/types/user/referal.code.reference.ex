defmodule JetzySchema.Types.User.Referral.Code.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.User.Referral.Code.Ecto.UniversalReference
end
