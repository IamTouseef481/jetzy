defmodule Data.Context.RegisterUserWithPrivateInterests do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.RegisterUserWithPrivateInterest

  @spec preload_all(RegisterUserWithPrivateInterest.t()) :: RegisterUserWithPrivateInterest.t()
  def preload_all(data), do: Repo.preload(data, [:private_interest, ])

end
