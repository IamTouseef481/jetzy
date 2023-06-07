defmodule Data.Context.UserInterests do
  import Ecto.Query, warn: false

  alias Data.Repo
  alias ApiWeb.Utils.Common
  alias Data.Context.{UserInterests, GuestInterests}
  alias Data.Schema.{Interest, UserInterest, User}

  @status :accepted

  @spec preload_all(UserInterest.t()) :: UserInterest.t()
  def preload_all(data), do: Repo.preload(data, [:user, :interest, ])

  def get_user_interest_ids_list(user_id) do
    UserInterest
    |> where([ui], ui.user_id == ^user_id)
    |> where([ui], ui.status == ^@status)
    |> select([ui], ui.interest_id)
    |> Repo.all()
  end

  def get_user_interests_list(user_id) do
    UserInterest
    |> where([ui], ui.user_id == ^user_id)
    |> where([ui], ui.status == ^@status)
    |> Repo.all()
  end

  def get_paginated_user_interests_list_by_user_id(user_id, page, page_size \\ 20) do
    popular_interest_ids = Common.popular_interest_ids()
    user_interest_ids = UserInterests.get_user_interest_ids_list(user_id)
    Interest
    |> where([i], i.status)
    |> where([i],  not i.is_private)  #TODO needs to show private interests of that user also
    |> order_by([i], desc: [i.id in ^user_interest_ids])
    |> order_by([i], desc: [i.id in ^popular_interest_ids])
    |> select([i, _], %{is_private: i.is_private, is_group_private: i.is_group_private,
    interest_name: i.interest_name, image_name: i.image_name,
    id: i.id, description: i.description, background_colour:
    i.background_colour, status: nil, created_by_id: i.created_by_id,
    deleted_at: i.deleted_at, inserted_at: i.inserted_at, updated_at: i.updated_at,
    small_image_name: i.small_image_name, is_deleted: i.is_deleted})
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_paginated_user_interests_list_by_device_id(device_id, page, page_size \\ 20) do
    popular_interest_ids = Common.popular_interest_ids()
    guest_interest_ids = GuestInterests.get_guest_interest_by_device_id(device_id)
    Interest
    |> where([i], i.status)
    |> where([i], not i.is_private)
    |> order_by([i], desc: [i.id in ^guest_interest_ids])
    |> order_by([i], desc: [i.id in ^popular_interest_ids])
    |> select([i], %{is_private: i.is_private, is_group_private: i.is_group_private,
    interest_name: i.interest_name, image_name: i.image_name,
    id: i.id, description: i.description, background_colour:
    i.background_colour, status: nil, created_by_id: i.created_by_id,
    deleted_at: i.deleted_at, inserted_at: i.inserted_at, updated_at: i.updated_at,
    small_image_name: i.small_image_name, is_deleted: i.is_deleted})
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_limited_user_interests_list(user_id) do
    UserInterest
    |> where([ui], ui.user_id == ^user_id)
    |> where([ui], ui.status == ^@status)
    |> join(:inner, [ui], u in Interest, on: u.id == ui.interest_id)
    |> select([ui, u], u.interest_name)
#    |> limit(^limit)
    |> Repo.all()
  end

  def delete_all_user_interests(user_id) do
    UserInterest
    |> where([ui], ui.user_id == ^user_id)
    |> Repo.delete_all()
  end

  def user_interest_exists_by_user_id(interest_id, user_id) do
    UserInterest
    |> where([ui], ui.interest_id == ^interest_id and ui.user_id == ^user_id)
    |> where([ui], ui.status == ^@status)
    |> Repo.exists?()
  end

  def get_interest_users(interest_id, page, page_size \\ 10) do
    UserInterest
    |> join(:inner, [ui], u in User, on: u.id == ui.user_id )
    |> where([ui], ui.interest_id == ^interest_id)
    |> where([ui], ui.status == ^@status)
    |> select([ui, u], u)
#    |> order_by([ui], [desc: ui.inserted_at])
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_interest_users_count(interest_id) do
    UserInterest
    |> join(:inner, [ui], u in User, on: u.id == ui.user_id )
    |> where([ui], ui.interest_id == ^interest_id)
    |> where([ui], ui.status == ^@status)
    |> select([ui, u], count(u))
    |> Repo.one
  end

  def get_last_member_joined_at(interest_id) do
    UserInterest
    |> where([ui], ui.interest_id == ^interest_id)
    |> order_by([ui], desc: ui.inserted_at)
    |> limit(1)
    |> select([ui], ui.inserted_at)
    |> Repo.one
  end

  def get_limited_public_user_interests_list(current_user_id, user_id) do
    current_user_id = UUID.string_to_binary!(current_user_id)
    user_id = UUID.string_to_binary!(user_id)

    query = "SELECT interest_name from ((SELECT interests.id, interests.interest_name
from interests
inner join user_interests ui
    on interests.id = ui.interest_id and user_id = $1
where  interests.is_private and ui.status = 'accepted'
INTERSECT
SELECT interests.id, interests.interest_name
from interests
         inner join user_interests ui
                    on interests.id = ui.interest_id and user_id = $2
where  interests.is_private and ui.status = 'accepted')
UNION DISTINCT
SELECT interests.id, interests.interest_name
from interests
         inner join user_interests ui
                    on interests.id = ui.interest_id and user_id = $3
                    where not interests.is_private and ui.status = 'accepted') as interest"

{:ok, result} = Ecto.Adapters.SQL.query(Repo, query, [current_user_id, user_id, user_id])
  List.flatten(result.rows)
  end

end
