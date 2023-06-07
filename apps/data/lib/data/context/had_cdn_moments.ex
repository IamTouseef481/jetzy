defmodule Data.Context.HadCdnMoments do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.HadCdnMoment

  @spec preload_all(HadCdnMoment.t()) :: HadCdnMoment.t()
  def preload_all(data), do: Repo.preload(data, [:moment, ])

end
