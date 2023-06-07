defmodule Data.Context.UserInterestTaggeds do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserInterestTagged

  @spec preload_all(UserInterestTagged.t()) :: UserInterestTagged.t()
  def preload_all(data), do: Repo.preload(data, [:interest, ])

end
