defmodule Data.Context.TestMoments do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.TestMoment

  @spec preload_all(nil | [TestMoment.t()] | TestMoment.t()) ::  nil | [TestMoment.t()] | TestMoment.t()
  def preload_all(data), do: Repo.preload(data, [:user, :shoutout, ])

end
