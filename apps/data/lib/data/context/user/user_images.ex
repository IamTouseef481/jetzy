defmodule Data.Context.UserImages do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserImage

  @spec preload_all(UserImage.t()) :: UserImage.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

  def get_by_user_id(user_id) do
    UserImage
    |> where([ui], ui.user_id == ^user_id)
    |> select([ui], fragment("COALESCE(max(?), 0)", ui.order_number))
    |> Repo.one()
  end

end
