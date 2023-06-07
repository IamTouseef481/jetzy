defmodule Data.Context.RoomUsers do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.{RoomUser, Room, User}

  @spec preload_all(RoomUser.t()) :: RoomUser.t()
  def preload_all(data), do: Repo.preload(data, [:room, :user])

  def user_exists_in_room(room_id, user_id) do
    RoomUser
    |> where([ru], ru.room_id == ^room_id)
    |> where([ru], ru.user_id == ^user_id)
    |> Repo.exists?()
  end

  def get_room_users(room_id, page \\ 1, page_size \\ 10) do
    RoomUser
    |> where([ru], ru.room_id == ^room_id)
    |> preload([:room, :user])
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_room_user_ids(room_id) do
    RoomUser
    |> where([ru], ru.room_id == ^room_id)
    |> select([ru], ru.user_id)
    |> Repo.all()
  end

  def get_room_id_by_referral_code(referral_code) do
    Data.Schema.RoomReferralCode
    |> where([r], r.referral_code == ^referral_code)
    |> select([r], %{room_id: r.room_id})
    |> Repo.one()
  end

  def get_oldest_room_user(room_id) do
    from(
    ru in RoomUser,
    where: ru.room_id == ^room_id and is_nil(ru.deleted_at),
    order_by: [asc: ru.inserted_at],
    limit: 1,
    select: ru
    )
    |> Repo.one()
  end

  def check_admin_exists?(room_id, user_id) do
    RoomUser
    |> where([ru], ru.room_id == ^room_id and ru.user_id != ^user_id and ru.user_role == "admin")
    |> Repo.all() != []
  end

  def room_user_exists?(room_id) do
    RoomUser
    |> where([ru], ru.room_id == ^room_id and is_nil(ru.deleted_at))
    |> Repo.exists?()
  end

  def count_room_users(room_id) do
    RoomUser
    |> where([rm], rm.room_id == ^room_id)
    |> select([rm], count(rm.id))
    |> Repo.one()
  end

  def is_group_admin?(user_id, room_id) do
    RoomUser
    |> join(:inner, [ru],r in Room, on: r.id == ru.room_id)
    |> where([ru, _], ru.user_id == ^user_id and ru.room_id == ^room_id)
    |> where([ru, r], r.room_type == "group_chat" and ru.user_role == "admin")
    |> Repo.all() != []
  end

  def room_users(room_id, page, search, page_size \\ 10) do
    RoomUser
    |> join(:inner, [ru], u in User, on: u.id == ru.user_id)
    |> where([ru, u], ru.room_id == ^room_id)
    |> where([ru, u], ilike(u.first_name, ^"%#{search}%") or ilike(u.last_name, ^"%#{search}%"))
    |> preload([:room, :user])
    |> Repo.paginate([page: page, page_size: page_size])
    end
end
