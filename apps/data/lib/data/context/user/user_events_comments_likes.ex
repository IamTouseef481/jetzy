defmodule Data.Context.UserEventsCommentsLikes do
  import Ecto.Query, warn: false
  alias Data.Repo

  alias Data.Schema.{UserEventCommentLike, RoomMessage, User, UserEvent}

  @spec preload_all(UserEventCommentLike.t()) :: UserEventCommentLike.t()
  def preload_all(data), do: Repo.preload(data, [:user_event_comment, :user])


  def get_like_by_comment_and_user_id(room_message_id, user_id) do
    UserEventCommentLike
    |> where([ld], ld.room_message_id == ^room_message_id)
    |> where([ld], ld.liked_by_id == ^user_id)
    |> Repo.one()
  end

  def get_user_event_by_room_message_id(room_message_id)do
    UserEvent
    |> join(:inner, [ue], rm in RoomMessage, on: rm.room_id == ue.room_id and rm.id == ^room_message_id)
    |> select([ue], ue.id)
    |> limit(1)
    |> Repo.one
  end

  def list_people_who_like(params, page_size \\ 20)
  def list_people_who_like(%{"comment_id" => item_id, "page" => page} = params, page_size) do
    search = if params["search"], do: params["search"], else: ""
    UserEventCommentLike
    |> join(:inner, [lk], u in User, on: u.id == lk.liked_by_id and lk.room_message_id == ^item_id)
    |> where([_lk, u], ilike(u.first_name, ^"%#{search}%"))
    |> or_where([_lk, u], ilike(u.last_name, ^"%#{search}%"))
    |> distinct([_lk, u], u.id)
    |> select([_lk, u], u)
    |> Repo.paginate(page: page, page_size: page_size)
  end


  def get_user_by_room_message_id(message_id) do
    RoomMessage
    |> where([ld], ld.id == ^message_id)
    |> Repo.one()
  end
  def get_likes_count_by_item_id(item_id) do
    UserEventCommentLike
    |> where([ld], ld.room_message_id == ^item_id)
    |> select([ld], count(ld.id))
    |> Repo.one()
  end
end
