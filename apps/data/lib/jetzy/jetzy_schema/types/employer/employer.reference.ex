defmodule JetzySchema.Types.Employer.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Employer.Ecto.UniversalReference
end
