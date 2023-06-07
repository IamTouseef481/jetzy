defmodule Data.Helper.UserFollowHelper do
  @moduledoc false

  alias Data.Repo
  alias Data.Schema.{User, UserFollow}
  alias Data.Context
  import Ecto.Query

  def duplicates() do
    duplicates = UserFollow
                 |> group_by([uf], [uf.followed_id, uf.follower_id])
                 |> having([uf], count(uf.id) > 1)
                 |> select([uf], %{
      followed_id: uf.followed_id,
      follower_id: uf.follower_id,
      cnt: fragment("count(?) as cnt", uf.id)
    })
    |> Repo.all()
    case duplicates do
      [%{cnt: cnt, followed_id: followed_id, follower_id: follower_id}|_] ->
        Enum.reduce(duplicates, [], fn dupl, acc ->
          data =
            UserFollow
            |> where([uf], uf.followed_id == ^dupl.followed_id and uf.follower_id == ^dupl.follower_id)
            |> order_by([uf], desc: uf.inserted_at)
            |> Repo.all()

          case data do
            any -> Enum.each(List.delete_at(data, 0), fn to_delete ->
              Context.delete(to_delete)
            end)
          end
        end
        )

      [] -> :ok
    end
  end
end