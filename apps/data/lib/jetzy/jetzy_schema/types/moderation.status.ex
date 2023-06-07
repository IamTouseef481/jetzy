defmodule JetzySchema.Types.Moderation.Status.Enum do
  use JetzySchema.Type.EnumTypeBehaviour, source: Jetzy.Moderation.Status.Enum.Ecto.EnumType
end
