defmodule Data.Context.UserReferences do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserReference

  @spec preload_all(UserReference.t()) :: UserReference.t()
  def preload_all(data), do: Repo.preload(data, [:user_interest, ])

end
