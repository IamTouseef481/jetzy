defmodule Data.Context.UserPostTypes do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserPostType

  @spec preload_all(UserPostType.t()) :: UserPostType.t()
  def preload_all(data), do: Repo.preload(data, [])

end
