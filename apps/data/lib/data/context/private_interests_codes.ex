defmodule Data.Context.PrivateInterestsCodes do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.PrivateInterestsCode

  @spec preload_all(PrivateInterestsCode.t()) :: PrivateInterestsCode.t()
  def preload_all(data), do: Repo.preload(data, [:interest, ])

end
