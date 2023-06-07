defmodule Data.Context.Rooms do
  import Ecto.Query, warn: false

  alias Data.Repo
  alias Data.Context.UserBlocks
  alias Data.Schema.{Room, User, RoomUser, RoomMessage}

  @spec preload_all(Room.t()) :: Room.t()
  def preload_all(data), do: Repo.preload(data, [:user_event, messages: [:sender, :message_images]])

  @spec preload_selective(Room.t()) :: Room.t()
  def preload_selective(data), do: Repo.preload(data, [:user_event])

  def get_user_chat_room(current_user_id, user_id) do
    Room
    |> join(:inner, [r], ru in Data.Schema.RoomUser, on: ru.room_id == r.id)
    |> where([r], r.room_type == "user_chat")
    |> where(
      [_, ru],
      fragment(
        "(select count(id) from room_users where room_users.room_id = ? and room_users.user_id in (?, ?)) = 2",
        ru.room_id,
        ^UUID.string_to_binary!(current_user_id),
        ^UUID.string_to_binary!(user_id)
      )
    )
    |> distinct([r], r.id)
    |> Repo.one()
  end

  def get_all_user_chat_rooms(user_id, page, page_size \\ 10) do
    blocked_user_ids = UserBlocks.get_blocked_user_ids(user_id)

    Room
    |> join(:inner, [r], ru in Data.Schema.RoomUser, on: ru.room_id == r.id)
#    |> join(:left, [r], rm in Data.Schema.RoomMessage, on: rm.room_id == r.id)
    |> join(:inner, [r, ru], u in User, on: ru.user_id == u.id)
    |> where([r, ru, _], r.room_type in ["user_chat", "event_chat", "group_chat"] and ru.user_id == ^user_id)
    |> where([_, ru, u], ru.user_id not in ^blocked_user_ids and u.is_deleted == false and u.is_deactivated == false and u.is_self_deactivated == false)
    |> where([_, ru, _], fragment(
        "(select count(id) from room_users where room_users.room_id = ?) >= 2",
        ru.room_id))
    |> where([r, _, _], is_nil(r.deleted_by) or r.deleted_by != ^user_id)
    |> order_by([r, _, _], [desc_nulls_last: r.last_message_at])
#    |> distinct([r, ...], r.id)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def search_chat_on_group_and_event(user_id, blocked_user_ids, query_string) do
    from(
      r in Room,
      join: ru in RoomUser, on: ru.room_id == r.id,
      left_join: rm in RoomMessage, on: rm.room_id == r.id,
      join: u in User, on: ru.user_id == u.id,
      where: r.room_type in ["event_chat", "group_chat"] and
             (ru.user_id == ^user_id and
              (ilike(r.group_name, ^"%#{query_string}%") or
               ilike(u.first_name, ^"%#{query_string}%") or
               ilike(u.last_name, ^"%#{query_string}%")
                )
               ),
      where: ru.user_id not in ^blocked_user_ids and u.is_deleted == false and u.is_deactivated == false and u.is_self_deactivated == false,
      where: fragment("(select count(id) from room_users where room_users.room_id = ?) >= 2", ru.room_id),
      order_by: [desc: rm.inserted_at],
      distinct: r
    )
  end

  def search_chat(user_id, query_string, page, page_size \\ 10) do
    blocked_user_ids = UserBlocks.get_blocked_user_ids(user_id)
    from(
      r in Room,
      left_join: ru in RoomUser, on: ru.room_id == r.id,
      left_join: rm in RoomMessage, on: rm.room_id == r.id,
      join: u in User, on: ru.user_id == u.id and ilike(u.first_name, ^"%#{query_string}%"),
      join: x in RoomUser, on: (ru.room_id == x.room_id and x.user_id == ^user_id),
      where: r.room_type in ["user_chat"],
      where: ru.user_id not in ^blocked_user_ids and u.is_deleted == false and u.is_deactivated == false and u.is_self_deactivated == false,
      where: fragment("(select count(id) from room_users where room_users.room_id = ?) >= 2", ru.room_id),
#      where: ilike(u.first_name, ^"%#{query_string}%") or ilike(u.last_name, ^"%#{query_string}%"),
      distinct: r.id,
      union: ^search_chat_on_group_and_event(user_id, blocked_user_ids, query_string)
    ) |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_group_name_by_room_id(room_id) do
    Room
    |> where([r], r.id == ^room_id)
    |> select([r], r.group_name)
    |> Repo.one
  end

  def check_room_exists?(room_id) do
    Room
    |> where([r], r.id == ^room_id)
    |> Repo.exists?()
  end

  def get_user_groups(user_id) do
    Room
    |> join(:inner, [r], ru in RoomUser,on: ru.room_id == r.id and ru.user_id == ^user_id)
    |> where([r, _], r.room_type == "group_chat")
    |> select([r, _], r.id)
    |> Repo.all
  end

end
