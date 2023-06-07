defmodule ApiWeb.Api.V1_0.InterestTopicView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.{UserChatView}
  alias  Data.Context

  def render("interest_topics.json", %{interest_topics: interest_topics} = data) do
#    %{interest_topics: render_many(interest_topics, InterestTopicView, "interest_topic.json")}
    current_user_id = data[:current_user_id]
    interest_topics = Enum.map(interest_topics, fn interest_topic ->
      render("interest_topic.json", %{interest_topic: interest_topic, current_user_id: current_user_id})
    end)
    %{interest_topics: interest_topics}
  end

  def render("show.json", %{interest_topic: interest_topic} = data) do
#    interest_topic_data = render_one(interest_topic, InterestTopicView, "interest_topic.json")
    interest_topic_data = render("interest_topic.json", %{interest_topic: interest_topic, current_user_id: data[:current_user_id]})
    %{interest_topic: interest_topic_data}
  end

  def render("interest_topic.json", %{interest_topic: interest_topic} = data) do
    current_user_id = data[:current_user_id]
    created_by = case interest_topic do
      %{created_by: %{id: user_id, first_name: fname, last_name: lname, image_name: image} } ->
        %{role_id: role_id} = Context.get_by(Data.Schema.UserRole, user_id: user_id)
        %{created_by: %{role_id: role_id, id: user_id, first_name: fname, last_name: lname, image_name: image}}
      %{created_by: %Ecto.Association.NotLoaded{}} -> %{created_by: nil}
      _ -> %{created_by: nil}
    end
    last_message = case Data.Context.RoomMessages.get_room_last_message(interest_topic.room_id, current_user_id) do
      %{} = last_message -> render_one(last_message, UserChatView, "user_message.json", as: :message)
      _ -> %{}
    end
    Map.merge(interest_topic, created_by) |> Map.merge(%{last_message: last_message}) |>
    Map.from_struct() |> Map.drop([:__meta__, :room, :interest])
  end

 def render("chat_group_members.json", %{room_user: room_user})do

    users_room_data = render_many(room_user, UserChatView, "room_user.json", as: :room_user)

    page_data = %{
      total_rows: room_user.total_entries,
      page: room_user.page_number,
      total_pages: room_user.total_pages
    }
    %{data: users_room_data, pagination: page_data}
  end

  def render("interest_topic.json", %{error: error}) do
    %{errors: error}
  end
end
