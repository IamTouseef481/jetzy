defmodule Data.Context.Interests do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.{Interest, UserInterest}
#  alias Data.Schema.User
#  alias Data.Schema.UserFriend
  alias ApiWeb.Utils.Common

  @status :accepted

  @spec preload_all(Interest.t()) :: Interest.t()
  def preload_all(data), do: Repo.preload(data, [])

  def interest_members_count(id) do
    Data.Schema.UserInterest
    |> where([ui], ui.interest_id == ^id and ui.status == ^@status)
    |> Repo.aggregate(:count)
  end

  # Get guest user interests with search params
  def get_interests_list_for_guest_with_search(page, search, page_size \\ 20) do
    query_for_guest_user_interest_list()
    |> where([i], fragment("? ilike ?", i.interest_name, ^"%#{search}%"))
    |> where([i], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", i.id))
    |> Repo.paginate(page: page, page_size: page_size)
  end

  # Get guest user interests without search params
  def get_interests_list_for_guest(page, page_size \\ 20) do
    query_for_guest_user_interest_list()
    |> where([i], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", i.id))
    |> Repo.paginate(page: page, page_size: page_size)
  end

  # Get interests with search params
  def get_interests_list_with_search(user_id, search, page, page_size \\ 20) do
    query_for_interest_list(user_id)
    |> where([i], fragment("? ilike ?", i.interest_name, ^"%#{search}%"))
    |> where([i], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", i.id))
    |> Repo.paginate(page: page, page_size: page_size)
  end

  # Get interests without search params
  def get_interests_list(user_id, page, page_size \\ 20) do
    query_for_interest_list(user_id)
    |> where([i], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", i.id))
    |> Repo.paginate(page: page, page_size: page_size)
  end

  # Get user private interests
  def get_user_private_interest_list(user_id, status, page, page_size \\ 10) do
    Interest
    |> join(:inner, [i], ui in UserInterest, on: i.id == ui.interest_id)
    |> where([ _, ui], ui.user_id == ^user_id)
    |> where([i, _], i.is_private == true)
    |> where([_, ui], ui.status == ^status)
    |> select([i, ui], %{is_private: i.is_private, is_group_private: i.is_group_private,
    interest_name: i.interest_name, image_name: i.image_name,
    id: i.id, description: i.description, background_colour:
    i.background_colour, status: ui.status, created_by_id: i.created_by_id,
    deleted_at: i.deleted_at, inserted_at: i.inserted_at, updated_at: i.updated_at,
    small_image_name: i.small_image_name, is_deleted: i.is_deleted, shareable_link: i.shareable_link})
    |> Repo.paginate(page: page, page_size: page_size)
  end

  # Get all public and private interests that current user followed
  defp query_for_interest_list(user_id) do
    Interest
    |> join(:left, [i], ui in Data.Schema.UserInterest, on: ui.interest_id == i.id and ui.user_id == ^user_id and ui.status == ^@status and ui.is_active)
    |> where([i], i.status)
    # |> where([i, ui], fragment("(?=false) or (?=? and ?=?)", i.is_private, ui.user_id, ^UUID.string_to_binary!(user_id), ui.status, @status))
    |> where([i, ui], fragment("(?=false) or (? is not null)", i.is_private, ui.interest_id))
    # |> where([i, ui], ui.user_id == ^user_id and ui.status == ^@status) # and i.is_private == true)
    # |> or_where([i, _], i.is_private == false)
    |> distinct([i, _], true)
    |> select([i, ui], %{is_private: i.is_private, is_group_private: i.is_group_private,
    interest_name: i.interest_name, image_name: i.image_name,
    id: i.id, description: i.description, background_colour:
    i.background_colour, status: ui.status, created_by_id: i.created_by_id,
    deleted_at: i.deleted_at, inserted_at: i.inserted_at, updated_at: i.updated_at,
    small_image_name: i.small_image_name, is_deleted: i.is_deleted })
    |> order_by([i, _], [desc: i.is_private])
  end

  # Get all public interests for guest users
  defp query_for_guest_user_interest_list do
    popular_ids = Common.popular_interest_ids()
    Interest
    |> where([i], i.is_private == false)
    |> where([i], i.status)
    |> select([i], %{is_private: i.is_private, is_group_private: i.is_group_private,
    interest_name: i.interest_name, image_name: i.image_name,
    id: i.id, description: i.description, background_colour:
    i.background_colour, status: nil, created_by_id: i.created_by_id,
    deleted_at: i.deleted_at, inserted_at: i.inserted_at, updated_at: i.updated_at,
    small_image_name: i.small_image_name, is_deleted: i.is_deleted })
    |> order_by([i], [desc: i.id in ^popular_ids])
  end

  def get_user_interest_meta(interest_id) do
    from(m in Data.Schema.UserInterestMeta,
      where: m.interest_id == ^interest_id
    ) |> Repo.one()
  end

#  defp select_custom_fields(i, ui \\ nil) do
#    user_interest_status = if ui != nil, do: ui.status, else: nil
#
#    %{is_private: i.is_private, is_group_private: i.is_group_private,
#      interest_name: i.interest_name, image_name: i.image_name,
#      id: i.id, description: i.description, background_colour:
#      i.background_colour, status: user_interest_status, created_by_id: i.created_by_id,
#      deleted_at: i.deleted_at, inserted_at: i.inserted_at, updated_at: i.updated_at,
#      small_image_name: i.small_image_name, is_deleted: i.is_deleted }
#  end

  def get_interest_ids do
    Interest
    |> select([i], i.id)
    |> Repo.all
  end

  def list(page, page_size) do
    Interest
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_interest_list_for_admin_with_search(search ,page, page_size) do
    Interest
    |> where([i], fragment("? ilike ?", i.interest_name, ^"%#{search}%"))
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def is_already_exist_interest_name(interest_name) do
    Interest
    |> where([i], i.interest_name == ^interest_name)
    |> Repo.exists?()
  end

  def get_limited_user_interests_list(user_id) do
    Interest
    |> join(:inner, [i], ui in UserInterest, on: i.id == ui.interest_id)
    |> where([_i, ui], ui.user_id == ^user_id and ui.status == @status)
    |> select([i], %{
      interest_id: i.id,
      interest_name: i.interest_name,
      small_image_name: i.small_image_name,
      image_name: i.image_name
    })
    |> Repo.all()
  end

  def delete_interest_by_user_id(_, _,created_by_id) do
    try do
      Interest
      |> where([i], i.created_by_id == ^created_by_id)
      |> Repo.update_all([set: [deleted_at: DateTime.utc_now(), is_deleted: true]])
      {:ok, :success}
    rescue
      e ->
        {:error, e}
    end
  end
end
