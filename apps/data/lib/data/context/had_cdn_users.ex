defmodule Data.Context.HadCdnUsers do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.HadCdnUser

  @spec preload_all(HadCdnUser.t()) :: HadCdnUser.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
