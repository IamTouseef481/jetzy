defmodule Data.Context.UserShoutoutImages do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserShoutoutImage

  @spec preload_all(UserShoutoutImage.t()) :: UserShoutoutImage.t()
  def preload_all(data), do: Repo.preload(data, [:shoutout, ])

  def get_shoutout_images(shoutout_id) do
    UserShoutoutImage
    |> where([si], si.shoutout_id == ^shoutout_id)
    |> Repo.all()
  end
end
