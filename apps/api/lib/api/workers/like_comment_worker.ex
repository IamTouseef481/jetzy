defmodule Api.Workers.LikeCommentWorker do
  use Oban.Worker, queue: :like_comment, max_attempts: 1

  alias Data.Schema.{UserEventLike, UserEvent, RoomMessage, RoomMessageMeta, User, InfluencerMessage}
  alias Data.Context.{UserEventLikes, UserEvents}
  alias Data.Context

  def perform(%Oban.Job{args: args}) do
    create_comment_and_broadcast_to_room(%{"message" => args["comment"], "sender_id" => args["sender_id"], "room_id" => args["room_id"], "post_owner_id" => args["post_owner_id"]})
    adding_like_post(args["post_id"], args)
  end

  def enqueue_like_comment_worker(schedule_in, params) do
    Api.Workers.LikeCommentWorker.new(
      params,
      queue: :like_comment,
      max_attempts: 1,
      schedule_in: schedule_in,
    )
    |> Oban.insert()
  end

  def create_comment_and_broadcast_to_room(%{"message" => nil} = params), do: :do_nothing
  def create_comment_and_broadcast_to_room(%{"message" => ""} = params), do: :do_nothing
  def create_comment_and_broadcast_to_room(%{"message" => _message} = params) do
    case Context.create(RoomMessage, params) do
      {:ok, %RoomMessage{} = room_message} ->
        base_url = JetzyModule.AssetStoreModule.image_base_url()
        sender = Context.get(User, params["sender_id"])
        payload = %{
          "user" => %{
            "isActive" => sender && sender.is_active,
            "userImage" => sender && sender.image_name,
            "userId" => sender && sender.id,
            "lastName" => sender && sender.last_name,
            "firstName" => sender && sender.first_name,
            "baseUrl" => "https://#{base_url}/",
          },
          "messageTime" => room_message.inserted_at,
          "messageId" => room_message.id,
          "messageImages" => [],
          "callbackVerification" => room_message.callback_verification,
          "parent_id" => room_message.parent_id
          }
        broadcast_to_event_comment_room(room_message.room_id, payload)
        {:error, _error} -> :do_nothing
    end

  end

  def adding_like_post(nil, _), do: :do_nothing
  def adding_like_post(item_id, comment_like) do
    case Context.get(UserEvent, item_id) do
      %UserEvent{} = post ->
        case UserEventLikes.get_like_by_post_and_user_id(item_id, comment_like["sender_id"]) do
          nil ->
            if comment_like["like"] == true do
              case Context.create(UserEventLike, %{
                liked: comment_like["like"],
                item_id: item_id,
                user_id: comment_like["sender_id"]
              }) do
                {:error, error} ->
                  {:error, error}
                {:ok, like} ->
                  ApiWeb.Utils.Common.update_points(post.user_id, :post_liked)
                  UserEvents.get_user_by_event_id(item_id)
              end
            end
          like_details ->
            if comment_like["like"] == false do
              Context.delete(like_details)
            end
        end
      nil ->
        {:error, "Something went wrong"}

      _ ->
        {:error, "something went wrong"}
    end
  end

  defp broadcast_to_event_comment_room(room_id, payload) do
    ApiWeb.Endpoint.broadcast(
    "event_comments:" <> room_id,
    "comment",
    payload
    )
  end
      
end