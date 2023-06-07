defmodule JetzySchema.Types.Transaction.Status.Enum do
  use JetzySchema.Type.EnumTypeBehaviour, source: Jetzy.Transaction.Status.Enum.Ecto.EnumType

end
