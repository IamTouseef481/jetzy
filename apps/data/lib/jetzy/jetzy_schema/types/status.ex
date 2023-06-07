defmodule JetzySchema.Types.Status.Enum do
  use JetzySchema.Type.EnumTypeBehaviour, source: Jetzy.Status.Enum.Ecto.EnumType
end
