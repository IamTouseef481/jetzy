defmodule JetzySchema.Types.Gender.Enum do
  use JetzySchema.Type.EnumTypeBehaviour, source: Jetzy.Gender.Enum.Ecto.EnumType

end
