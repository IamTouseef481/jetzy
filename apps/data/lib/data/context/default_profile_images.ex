defmodule Data.Context.DefaultProfileImages do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.DefaultProfileImage

  @spec preload_all(DefaultProfileImage.t()) :: DefaultProfileImage.t()
  def preload_all(data), do: Repo.preload(data, [])

  def get_random() do
    DefaultProfileImage
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> Repo.one()
  end
end
