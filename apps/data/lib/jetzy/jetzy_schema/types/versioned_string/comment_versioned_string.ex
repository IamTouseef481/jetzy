defmodule JetzySchema.Types.CommentVersionedString.Reference do
  use JetzySchema.Type.ReferenceTypeBehaviour, source: Jetzy.CommentVersionedString.Ecto.UniversalReference
end
