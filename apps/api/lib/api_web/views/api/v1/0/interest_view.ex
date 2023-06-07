defmodule ApiWeb.Api.V1_0.InterestView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.InterestView
  alias ApiWeb.Utils.Common
  alias Data.Schema.{User, UserInterestMeta}
  alias Data.Context
  alias Data.Context.{UserInterests}

  def render("interests.json", %{interests: interests}) do
    interests_data = render_many(interests, InterestView, "interest.json", as: :interests)
    page_data = %{
      total_rows: interests.total_entries,
      page: interests.page_number,
      total_pages: interests.total_pages
    }
    %{
      data: interests_data, pagination: page_data
    }
  end


  def render("interest.json", %{user_interest: user_interest}) do
    interest =  Map.from_struct(user_interest) |> Map.drop([:__meta__, :user, :interest])
    %{user_interest: interest}
  end
#-------------------------------------------------------------------


  def render("private_interests.json", %{interests: interests}) do
    interests_data = render_many(interests, InterestView, "private_interest.json", as: :private_interest)
    page_data = %{
      total_rows: interests.total_entries,
      page: interests.page_number,
      total_pages: interests.total_pages
    }
    %{
      data: interests_data, pagination: page_data
    }
  end


  def render("private_interest.json", %{private_interest: private_interest}) do
    private_interest
    if is_nil(private_interest.created_by_id) do
      private_interest
    else
      result = case Data.Context.get(User, private_interest.created_by_id) do
        nil -> nil
        data -> ApiWeb.Api.V1_0.UserView.render("user.json", %{user: data})
      end
      Map.put(private_interest, :user, result)
    end
  end

#  -----------------------------------------------------
  def render("interest.json", %{successful: result, skipped: skipped}) do
    %{successful: result, skipped: skipped}
  end

  def render("interest_topic.json", %{interest_topic: topic}) do
    last_message = case Data.Context.RoomMessages.get_room_last_message(topic.room_id) do
      %{message: last_message} -> last_message
      _ -> ""
    end
    %{
      id: topic.id,
      topic_name: topic.topic_name,
      description: topic.description,
      last_message: last_message
    }
  end

  def render("show.json", %{interest: interest} = data) do
    current_user_id = data[:current_user_id]
    interest = Data.Context.preload_selective(interest, [:interest_topics, :user_interest_meta])
    interest =
      if is_nil Map.get(interest, :user_interest_meta) do
        with total_members <- UserInterests.get_interest_users_count(interest.id),
             last_member_joined_at <- UserInterests.get_last_member_joined_at(interest.id),
             {:ok, %UserInterestMeta{} = user_interest_meta} <- Context.create(
               UserInterestMeta,
               %{total_members: total_members, last_member_joined_at: last_member_joined_at}
             ) do
              Map.put(interest, :user_interest_meta, user_interest_meta)
          end
      else
        interest
      end
    last_member_joined_at = make_time_string(interest.user_interest_meta && interest.user_interest_meta.last_member_joined_at)
    last_message_at = make_time_string(interest.user_interest_meta && interest.user_interest_meta.last_message_at)
    interest_topics =  Data.Context.InterestTopics.get_interest_topics_by_interest_id(interest.user_id, interest.id, 1)
    %{interest_topics: response} =  ApiWeb.Api.V1_0.InterestTopicView.render("interest_topics.json", %{interest_topics: interest_topics, current_user_id: current_user_id})
    response = %{
      id: interest.id,
      image_name: interest.image_name,
      interest_description: interest.description,
      interest_name: interest.interest_name,
      small_image_name: interest.small_image_name,
      blur_hash: interest.blur_hash,
      status: (if is_boolean(interest.status), do: nil, else: interest.status),
      event_members_count: interest.user_interest_meta && interest.user_interest_meta.total_members,
      last_message_at: last_message_at,
      last_member_joined_at: last_member_joined_at,
      shareable_link: interest.shareable_link,
      users:
        render_many(interest.interest_users, ApiWeb.Api.V1_0.UserInterestView, "interests_user.json",
          as: :user
        ),
      events:
        render_many(interest.interest_events, ApiWeb.Api.V1_0.UserEventView, "user_event.json",
          as: :user_event
        ),
      interest_topics: response,
#        render_many(interest_topics, ApiWeb.Api.V1_0.InterestTopicView, "interest_topic.json",
#          as: :interest_topic
#        )
      created_by_id: interest.created_by_id
    }
  end

  def render("interest.json", %{interest: interest}) do
    data = Map.from_struct(interest) |> Map.drop([:__meta__, :interest_topics, :user_interest_meta, :created_by, :user_events])
    check_status = if is_boolean(data.status), do: Map.merge(data, %{status: nil}), else: data
    if is_nil(check_status.created_by_id) do
      check_status
    else
      result = case Data.Context.get(User, check_status.created_by_id) do
        nil -> nil
        data -> ApiWeb.Api.V1_0.UserView.render("user.json", %{user: data})
      end
      Map.put(check_status, :user, result)
    end
  end

  def render("interest.json", %{interests: interests}) do
    if is_nil(interests.created_by_id) do
      interests
    else
      result = case Data.Context.get(User, interests.created_by_id) do
        nil -> nil
        data -> ApiWeb.Api.V1_0.UserView.render("user.json", %{user: data})
      end
      Map.put(interests, :user, result)
    end

  end

  def render("interest.json", %{error: error}) do
    %{errors: error}
  end

  def render("user_interests.json", %{interest_users: interest_users}) do
    interest_data = render_many(interest_users, ApiWeb.Api.V1_0.UserInterestView, "interests_user.json",
      as: :user)
    page_data = %{
      total_rows: interest_users.total_entries,
      page: interest_users.page_number,
      total_pages: interest_users.total_pages
    }
    %{data: interest_data, pagination: page_data}
  end

  def render("user_events.json", %{user_events: user_events}) do
    event_data = render_many(user_events, ApiWeb.Api.V1_0.UserEventView, "events_interest.json",
      as: :interest_event
    )
    page_data = %{
      total_rows: user_events.total_entries,
      page: user_events.page_number,
      total_pages: user_events.total_pages
    }
    %{data: event_data, pagination: page_data}
  end

  def render("interest_topics.json", %{interest_topics: interest_topics} = data) do
#    interest_topics_data = render_many(interest_topics, ApiWeb.Api.V1_0.InterestTopicView, "interest_topic.json",
#      as: :interest_topic
#    )
    interest_topics_data = Enum.map(interest_topics, fn interest_topic ->
      ApiWeb.Api.V1_0.InterestTopicView.render("interest_topic.json", %{interest_topic: interest_topic, current_user_id: data[:current_user_id]})
    end)
    page_data = %{
      total_rows: interest_topics.total_entries,
      page: interest_topics.page_number,
      total_pages: interest_topics.total_pages
    }
    %{data: interest_topics_data, pagination: page_data}
  end

  def render("user_interests_list.json", %{interest_list: interest_list}) do
    interest_list
  end

  def render("message.json", %{message: message}) do
    %{message: message}
  end

  def make_time_string(time) when not is_nil(time) do
    time_string = DateTime.diff(DateTime.utc_now(), time)
                  |> Common.convert_seconds_to_readable_string()
    "#{time_string} ago"
  end
  def make_time_string(_), do: "No Activity"

end
