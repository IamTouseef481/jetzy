defmodule Data.Context.RoomMessageMetas do

  import Ecto.Query, warn: false
  alias Data.Schema.{RoomMessageMeta, Room}
  alias Data.Context.{RoomUsers}
  alias Data.Context
  alias Data.Repo


  def populate_room_message_meta(room_id, room_message_id, current_user_id, active_users)do
    user_ids = RoomUsers.get_room_user_ids(room_id)
    Enum.each(user_ids, fn user_id ->
      Context.create(RoomMessageMeta,
        %{room_message_id: room_message_id,
          room_id: room_id,
          user_id: user_id,
          is_read: user_id == current_user_id || user_id  in active_users
        }
      )
    end)
  end

  def update_message_read_status(user_id, room_id)do
    RoomMessageMeta
    |> where([rmm], rmm.room_id == ^room_id)
    |> where([rmm], rmm.user_id == ^user_id)
    |> where([rmm], rmm.is_read == false)
    |> Repo.update_all([set: [is_read: true]])
  end

  def all_room_users_read_message?(room_id) do
    result = RoomMessageMeta
    |> where([rmm], rmm.room_id == ^room_id and rmm.is_read == false)
    |> Repo.all()

    result == []
  end

  def get_count_of_unread_message(user_id, room_id) do
    RoomMessageMeta
    |> where([rmm], rmm.user_id == ^user_id and rmm.room_id == ^room_id and rmm.is_read == false)
    |> select([rmm], count(rmm.id))
    |> Repo.one
  end

  def get_count_of_unread_chats(user_id) do
#    RoomMessageMeta
#    |> where([rmm], rmm.user_id == ^user_id and rmm.is_read == false)
#    |> group_by([rmm], rmm.room_id)
#    |> distinct([rmm], rmm.room_id)
#    |> select([rmm], count(rmm.room_id))
#    |> Repo.one
    from(
    rmm in RoomMessageMeta,
    join: r in Room, on: r.id == rmm.room_id,
    where: rmm.user_id == ^user_id and rmm.is_read == false and r.room_type in ["user_chat", "event_chat", "group_chat"],
    group_by: rmm.room_id,
    select: count(fragment "distinct ?" , rmm.room_id)
    ) |> Repo.all |> Enum.count()
  end
  
  def check_message_read_by_message_id?(message_id) do
    result = RoomMessageMeta
             |> where([rmm], rmm.room_message_id == ^message_id and rmm.is_read == false)
             |> Repo.all()

    result == []
  end

  def soft_delete_message(user_id, room_message_ids) do
    RoomMessageMeta
    |> where([rmm], rmm.user_id == ^user_id and rmm.room_message_id in ^room_message_ids)
    |> Repo.update_all([set: [is_deleted: true]])
  end

  def soft_delete_all_messages(user_id, room_id) do
    RoomMessageMeta
    |> where([rmm], rmm.user_id == ^user_id and rmm.room_id == ^room_id)
    |> Repo.update_all([set: [is_deleted: true]])
  end

  def soft_delete_messages_by_message_ids(_, _, message_ids) do
    try do
      RoomMessageMeta
      |> where([rmm], rmm.room_message_id in ^message_ids)
      |> Repo.update_all([set: [is_deleted: true]])
      {:ok, :success}
    rescue
      e ->
        {:error, e}
    end
  end
end
