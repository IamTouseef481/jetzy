defmodule Data.Context.UserShoutoutsImages do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserShoutoutsImage

  @spec preload_all(UserShoutoutsImage.t()) :: UserShoutoutsImage.t()
  def preload_all(data), do: Repo.preload(data, [:shoutout, ])

  def get_all_by_post_id(shoutout_id) do
    from(usi in UserShoutoutsImage, where: usi.shoutout_id == ^shoutout_id)
    |> Repo.all()
  end

end
