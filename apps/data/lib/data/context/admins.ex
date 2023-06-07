defmodule Data.Context.Admins do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.{Admin, UserFollow, User}

  @spec preload_all(Admin.t()) :: Admin.t()
  def preload_all(data), do: Repo.preload(data, [])

  def paginate_users_for_admin(query, post_owner_id , page, page_size) do
    query
    |> join(:left, [u], uf in UserFollow, on: uf.followed_id == ^post_owner_id and uf.follower_id == u.id)
    |> select([u, uf],
         %{
           id: u.id,
           first_name: u.first_name,
           last_name: u.last_name,
           email: u.email,
           image_name: u.image_name,
           small_image_name: u.small_image_name,
           current_city: u.current_city,
           gender: u.gender,
           longitude: u.longitude,
           latitude: u.latitude,
           current_country: u.current_country,
           dob_full: u.dob_full,
           is_active: u.is_active,
           home_town_city: u.home_town_city,
           app_version: nil,
           login_type: u.login_type,
           is_deleted: u.is_deleted,
           is_deactivated: u.is_deactivated,
           jetzy_exclusive_status: u.jetzy_exclusive_status,
           jetzy_select_status: u.jetzy_select_status,
           user_verification_image: u.user_verification_image,
           inserted_at: u.inserted_at,
           effective_status: u.effective_status,
           influencer_level: u.influencer_level,
           user_level: u.user_level,
           follow_status: fragment(
             "case when ? is not null and ? is not null and ? = 'followed' then 'followed'
      when ? is not null and ? is not null and ? = 'requested' then 'requested'
      else null
      end as follow_status
", uf.followed_id, uf.follower_id, uf.follow_status, uf.followed_id, uf.follower_id, uf.follow_status
           )
         }
      )
  |> Repo.paginate(%{page: page, page_size: page_size})
  end

  def get_following_status(_, [""]), do: %{}
  def get_following_status(followed_id, followers_ids) do
    User
    |> join(:left, [u], uf in UserFollow, on: u.id == uf.follower_id and uf.followed_id == ^followed_id)
    |> where([u, _], u.id in ^followers_ids)
    |> select([u, uf], %{
      followed_id: ^followed_id,
      follower_id: u.id,
      follow_status: fragment(
        "case when ? is not null and ? is not null and ? = 'followed' then 'followed'
      when ? is not null and ? is not null and ? = 'requested' then 'requested'
      else null
      end as follow_status
", uf.followed_id, uf.follower_id, uf.follow_status, uf.followed_id, uf.follower_id, uf.follow_status
      )
    })
    |> Repo.all
  end

end
