defmodule JetzySchema.Types.Sphinx.Index.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.Sphinx.Index.Ecto.UniversalReference
end
