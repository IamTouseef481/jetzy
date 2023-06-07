defmodule Data.Context.UserProfileImages do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserProfileImage

  @spec preload_all(UserProfileImage.t()) :: UserProfileImage.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
