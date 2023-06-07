defmodule Data.Context.ShoutoutTypes do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.ShoutoutType

  @spec preload_all(ShoutoutType.t()) :: ShoutoutType.t()
  def preload_all(data), do: Repo.preload(data, [])

  def list_shoutout_types() do
    ShoutoutType
    |> order_by([st], st.sort_order)
    |> Repo.all()
  end

  def get_by_user_id(user_id) do
    ShoutoutType
    |> where([st], fragment("? in (select distinct shoutout_type_id from user_shoutouts where user_id = ?)", st.id, ^UUID.string_to_binary!(user_id)))
    |> Repo.all()
  end
end
