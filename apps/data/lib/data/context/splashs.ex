defmodule Data.Context.Splashes do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.Splash

  @spec preload_all(Splash.t()) :: Splash.t()
  def preload_all(data), do: Repo.preload(data, [])

end
