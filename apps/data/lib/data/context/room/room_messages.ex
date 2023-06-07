defmodule Data.Context.RoomMessages do
  import Ecto.Query, warn: false

  alias Data.Repo
  alias Data.Context.UserBlocks
  alias Data.Schema.{RoomMessage, User, RoomUser, RoomMessageMeta}
  require Logger

  @spec preload_all(RoomMessage.t(), []) :: RoomMessage.t()
  def preload_all(data, preloads \\ [:sender, :room, :message_images]), do: Repo.preload(data, preloads)

  def get_event_attendees(room_id, user_id) do
    RoomMessage
    |> join(:inner, [ui], u in User, on: ui.sender_id == u.id)
    |> where([ui], ui.room_id == ^room_id)
    |> where([ui], ui.sender_id != ^user_id)
    |> distinct([ui], ui.sender_id)
    |> select([ui, u], %{user_id: u.id, first_name: u.first_name, last_name: u.last_name, image_name: u.image_name})
    |> Repo.all()
  end

  def get_event_attendees(room_id, user_id, page, page_size \\ 10) do
    blocked_user_ids = UserBlocks.get_blocked_user_ids(user_id)

    RoomMessage
    |> join(:inner, [rm], u in User, on: rm.sender_id == u.id)
    |> where([rm, _], rm.room_id == ^room_id)
    |> where([rm, _], rm.sender_id != ^user_id)
    |> where([rm, u], u.id not in ^blocked_user_ids and u.is_deleted == false and u.is_deactivated == false and u.is_self_deactivated == false)
    |> distinct([rm, _], rm.sender_id)
    |> select([rm, u], %{user_id: u.id, first_name: u.first_name, last_name: u.last_name, image_name: u.image_name
#      is_member: not is_nil(fragment("SELECT TRUE FROM room_users WHERE room_id = ? AND user_id = ?", rm.room_id, rm.sender_id))
    })
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def is_member(room_id, sender_id) do
    RoomUser
    |> where([ru], ru.room_id == ^room_id)
    |> where([ru], ru.user_id == ^sender_id)
    |> select([ru], ru.id)
    |> limit(1)
    |> Repo.one()
  end


  def count_room_messages(nil) do
    0
  end
  
  def count_room_messages(room_id) do
    RoomMessage
    |> where([c], c.room_id == ^room_id and is_nil(c.parent_id))
    |> where([c], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", c.id))
    |> select([c], count(c.id))
    |> Repo.one()
  end


  def get_by_room_id(room_id, page, page_size \\ 10)
  def get_by_room_id(nil, page, page_size) do
    from(
      c in RoomMessage,
      where: (false and is_nil(c.parent_id)),
      order_by: [desc: c.inserted_at],
      preload: [:sender, :message_images]
    )
    |> Repo.paginate(page: page, page_size: page_size)
  end
  
  def get_by_room_id(room_id, page, page_size) do
    from(
      c in RoomMessage,
      where: (c.room_id == ^room_id and is_nil(c.parent_id)),
      order_by: [desc: c.inserted_at],
      preload: [:sender, :message_images]
    )
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def list_by_parent_id(model, message_id, page, page_size \\ 10) do
    from(m in model,
      where: m.parent_id == ^message_id,
      order_by: [asc: m.inserted_at],
      preload: [:sender, :message_images])
    |> where([m], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", m.id))
    |> Repo.paginate([page: page, page_size: page_size])
  end

  def count_replies(message_id) do
    RoomMessage
    |> where([c], c.parent_id == ^message_id)
    |> where([c], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", c.id))
    |> select([c], count(c.id))
    |> Repo.one()
  end

  def get_messages_by_room(room_id, page, current_user_id, page_size \\ 10) do
    blocked_user_ids = UserBlocks.get_blocked_user_ids(current_user_id)

    RoomMessage
    |> join(:inner, [rm], rmm in RoomMessageMeta, on: (rmm.room_message_id == rm.id and rmm.user_id == ^current_user_id and rmm.is_deleted == false))
    |> where([rm], rm.room_id == ^room_id)
    |> where([rm], is_nil(rm.parent_id))
    |> where([rm], rm.sender_id not in ^blocked_user_ids)
#    |> where([rm, rmm], rmm.user_id == ^current_user_id)
    |> order_by([rm], [desc: rm.inserted_at])
#    |> distinct([rm, _], rm.id)
    |> preload([:sender, :message_images, :room_message_meta, [replies: [:room_message_meta, :sender, :message_images]]])
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_room_last_message(room_id) do
    RoomMessage
    |> where([ui], ui.room_id == ^room_id and is_nil(ui.parent_id))
    |> order_by([ui], [desc: ui.inserted_at])
    |> preload([:sender, :message_images, :room_message_meta])
    |> limit(1)
    |> Repo.one()
  end
  def get_room_last_message(room_id, user_id) do

    RoomMessage
    |> join(:inner, [ui], rmm in RoomMessageMeta, on: rmm.room_message_id == ui.id and rmm.user_id == ^user_id)
    |> join(:inner, [ui, rmm], ru in RoomUser, on: ru.room_id == ^room_id and ru.user_id == ^user_id)
    |> where([ui, ...], ui.room_id == ^room_id)
    |> where([_, rmm, _], rmm.is_deleted == false)
#    |> where([ui, _, ru], ui.inserted_at > ru.inserted_at)
    |> order_by([ui], [desc: ui.inserted_at])
    |> preload([:sender, :message_images, :room_message_meta])
    |> limit(1)
    |> Repo.one()
  end

  #  @spec list_by(any(), any()) :: list(struct()) | []
  def list_by(model, by, page, page_size \\ 10) do
    from(m in model,
      where: m.room_id == ^by and is_nil(m.parent_id),
      order_by: [desc: m.inserted_at])
    |> where([m], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", m.id))
    |> Repo.paginate(page: page, page_size: page_size)
  end

  ####### from CommentReplies Context

  def get_user_by_parent_sref(parent_sref) do
    RoomMessage
    |> join(:inner, [us], u in User, on: u.id == us.user_id)
    |> where([us, _], us.id == ^parent_sref)
    |> select([us, u], %{id: u.id, email: u.email, user_id: us.user_id})
    |> Repo.one()
  end
  def get_user_ids_commented_on_specific_post(post, sender_id) do
    from(
      c in RoomMessage,
      where: c.room_id == ^post.room_id and c.sender_id != ^sender_id,
      distinct: c.sender_id,
      select: c.sender_id
    )
    |> Repo.all()
  end

  def verify_callback_verification(callback_verification) do
    RoomMessage
    |> where([rm], rm.callback_verification == ^callback_verification)
    |> Repo.exists?() && :exists || :not_exists
  end

  def get_user_messages_by_user_id(user_id) do
    RoomMessage
    |> where([rm], rm.sender_id == ^user_id)
    |> select([rm], rm.id)
    |> Repo.all()
  end

  def delete_user_messages(_, _, user_id) do
    try do
      RoomMessage
      |> where([rm], rm.sender_id == ^user_id)
      |> Repo.update_all([set: [deleted_at: DateTime.utc_now()]])
      {:ok, :success}
    rescue
      e ->
        {:error, e}
    end

  end

end
