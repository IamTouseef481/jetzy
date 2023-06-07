defmodule Data.Context.UserMomentsImages do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserMomentsImage

  @spec preload_all(UserMomentsImage.t()) :: UserMomentsImage.t()
  def preload_all(data), do: Repo.preload(data, [:moment, ])

end
