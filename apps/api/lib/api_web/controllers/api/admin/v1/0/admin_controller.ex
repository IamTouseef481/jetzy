#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.Admin.V1_0.AdminController do
  @moduledoc """
  Jetzy Admin Api Controller.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use Filterable.Phoenix.Controller
  import Ecto.Query, warn: false
  import Ecto.Multi
  alias Data.Repo

  use PhoenixSwagger
  alias Data.Context
  alias Data.Context.Users
  alias ApiWeb.Api.V1_0.UserEventController
  alias Data.Context.{UserEvents, RoomUsers, UserEventLikes, InfluencerMessages, Admins, Users}
  alias Data.Schema.{User, Interest, UserEvent, RoomMessage, RoomMessageMeta, UserEventLike, Status,
    InfluencerMessage, UserFollow}
  alias Api.Mailer
  alias Api.Workers.LikeCommentWorker
  alias ApiWeb.Utils.Common

  use Data.Helper.SeedHelper
  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # make_interest_public/2
  #----------------------------------------------------------------------------
  swagger_path :make_interest_public do
    get("/v1.0/admin/public-interest/{id}")
    summary("Make interest public")
    description("Make interest public")
    produces("application/json")
    security [%{Bearer: []}]
    parameters do
      id(:path, :string, "Interests ID", required: true)
    end
    response(200, "Ok", Schema.ref(:Interest))
  end

  @doc """
  Set interest to public
  """
  def make_interest_public(conn, %{"id" => id}) do
    %User{} = _user = Guardian.Plug.current_resource(conn)
    with %Interest{} = interest <- Context.get(Interest, id),
      {:ok, %Interest{} = interest} <- Context.update(Interest, interest, %{is_private: false}) do

      render(conn, "interest.json", %{interest: interest})
    end
  end


  #----------------------------------------------------------------------------
  # list_users/2
  #----------------------------------------------------------------------------
  swagger_path :list_users do
    get "/v1.0/admin/list-users"
    summary "List Users with Active Status"
    description "List Users with Active Status"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      page :query, :integer, "Page no. used for pagination", required: true
      page_size :query, :integer, "Page Size for pagination"
      active_status :query, :boolean, "Whether the users are active or not"
      first_name :query, :string, "User First Name"
      last_name :query, :string, "User Last Name"
      email :query, :string, "Email ID"
      home_town_city :query, :string, "Home Town City"
      last_login :query, :string, "Last Login Time"
      device_type :query, :array, "Device Type",
        items: [type: :string, enum: [:android, :iphone]]
      app_version :query, :string, "App Version"
      login_type :query, :string, "Login Type"
      is_referral :query, :boolean, "Set If the user is referred or not"
      is_deleted :query, :boolean, "Set If the user is deleted or not"
      is_deactivated :query, :boolean, "Set If the user is deactivated or not"
      inserted_at :query, :string, "User from a specific date"
      effective_status :query, :string, "Effective User Status (active, private, pending, deactivated, deleted)"
      influencer_level :query, :array, "Influencer Level",
                  items: [type: :string, enum: [:none, :basic, :standard, :celebrity]]
      search :query, :string, "A global search string for first_name, last_name and email"
      post_owner_id(:query, :string, "Id of the creator of the post")
    end
    response 200, "Ok", Schema.ref(:Users)
  end
  @doc """
  Fetch list of users.
  """
  def list_users(conn, %{"page" => page} = params) do
    page_size = if Map.has_key?(params, "page_size"), do: params["page_size"], else: 200
    users = if !Map.has_key?(params, "post_owner_id") do
      filter_users(User, params)
      |> Repo.paginate(page: page, page_size: page_size)
      else
      query = filter_users(User, params)
      Admins.paginate_users_for_admin(query, params["post_owner_id"], page, page_size)
    end

    render(conn, "users.json", %{users: users})
  end

  #----------------------------------------------------------------------------
  # update_user_active_status/2
  #----------------------------------------------------------------------------
  swagger_path :update_user_active_status do
    put "/v1.0/admin/user-status"
    summary "Set a user status to Active or Inactive"
    description "Allows the admin to set the user's is_active key to TRUE or FALSE"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      user_id :query, :string, "User ID"
      email :query, :string, "Email ID"
      body :body, Schema.ref(:UserStatus), "Set is_active, or is_deactivated keys etc.", required: true
    end
    response 200, "Ok", Schema.ref(:User)
  end
  @doc """
  Update user's active flag.
  """
  def update_user_active_status(conn, %{"user_id" => user_id} = params) do
    with %User{} = user <- Context.get(User, user_id),
         {:ok, updated_user} <- Context.update(User, user, params) do
      cond do
        (params["is_deleted"] == false && user.is_deleted == true) ||
          (params["is_deactivated"] == false && user.is_deactivated == true) ->
          Api.Mailer.send_direct_login_email(updated_user)
          render(conn, "user.json", %{user: updated_user})

        (params["is_deleted"] == true && user.is_deleted == false) ||
          (params["is_deactivated"] == true && user.is_deactivated == false) ->
          params = %{notification: "You account has been deactivated", template_name: "account_deactivation.html"}
          Mailer.send_email_deactivation_email(%{email: updated_user.email, first_name: updated_user.first_name}, params)
          render(conn, "user.json", %{user: updated_user})

        (params["is_deleted"] == true && user.is_deleted == true) ||
          (params["is_deactivated"] == true && user.is_deactivated == true) ->
          render(conn, "message.json", %{message: "Account is already deactivated"})

        (params["is_deleted"] == false && user.is_deleted == false) ||
          (params["is_deactivated"] == false && user.is_deactivated == false) ->
          render(conn, "message.json", %{message: "Account is already active"})
        true ->
          try do
            ApiWeb.Endpoint.broadcast("backend:#{user.id}", "refresh-cache", %{subject: "active-user"})
          rescue _ -> :error
          catch
            :exit, _ -> :error
            _ -> :error
          end
          render(conn, "user.json", %{user: updated_user})
      end
    else
      nil -> render(conn, "error.json", %{error: "User not found"})
      {:error, changeset} -> render(conn, "error.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
      _ -> render(conn, "error.json", %{error: "Something went wrong"})
    end
  end
  def update_user_active_status(conn, %{"email" => email} = params) do
    with %User{} = user <- Context.get_by(User, [email: email]),
         {:ok, updated_user} <- Context.update(User, user, params) do
      cond do
        (params["is_deleted"] == false && user.is_deleted == true) ||
          (params["is_deactivated"] == false && user.is_deactivated == true) ->
          Api.Mailer.send_direct_login_email(updated_user)
          render(conn, "user.json", %{user: updated_user})

        (params["is_deleted"] == true && user.is_deleted == false) ||
          (params["is_deactivated"] == true && user.is_deactivated == false) ->
          params = %{notification: "You account has been deactivated", template_name: "account_deactivation.html"}
          Mailer.send_email_deactivation_email(%{email: email, first_name: updated_user.first_name}, params)
          render(conn, "user.json", %{user: updated_user})

        (params["is_deleted"] == true && user.is_deleted == true) ||
          (params["is_deactivated"] == true && user.is_deactivated == true) ->
          render(conn, "message.json", %{message: "Account is already deactivte"})

        (params["is_deleted"] == false && user.is_deleted == false) ||
          (params["is_deactivated"] == false && user.is_deactivated == false) ->
          render(conn, "message.json", %{message: "Account is already activte"})

        true ->
          try do
            ApiWeb.Endpoint.broadcast("backend:#{user.id}", "refresh-cache", %{subject: "active-user"})
          rescue _ -> :error
          catch
            :exit, _ -> :error
            _ -> :error
          end
          render(conn, "user.json", %{user: updated_user})
      end

    else
      nil -> render(conn, "error.json", %{error: "User not found"})
      {:error, changeset} -> render(conn, "error.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
      _ -> render(conn, "error.json", %{error: "Something went wrong"})
    end
  end

  #----------------------------------------------------------------------------
  # list_users/2
  #----------------------------------------------------------------------------
  swagger_path :user_detail do
    get "/v1.0/admin/user-detail"
    summary "User Details"
    description "User Details"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      user_id :query, :string, "User ID", required: true
    end
    response 200, "Ok", Schema.ref(:Users)
  end
  @doc """
  Fetch list of users.
  """
  def user_detail(conn, %{"user_id" => user_id}) do
    %{id: current_user_id} = Guardian.Plug.current_resource(conn)
    with %User{} = user <- Context.get(User, user_id) do
      user = ApiWeb.Api.V1_0.UserController.add_more_fields(user) |> ApiWeb.Api.V1_0.UserController.get_follow_status(user_id, current_user_id)
      render(conn, "user_detail.json", %{user: user, current_user_id: current_user_id})
    else
      nil -> render(conn, "error.json", %{error: ["User does not exist"]})
    end
  end


    #----------------------------------------------------------------------------
    # post_influences
    #----------------------------------------------------------------------------
    swagger_path :post_influences_by_id do
      put("/v1.0/admin/post/{id}/post-influences")
      summary("Add comments and likes on existing post")
      description("Add comments and likes on existing post")
      produces("application/json")
      security([%{Bearer: []}])

      parameters do
        id(:path, :string, "Post id", required: true)
        body(:body, Schema.ref(:PostInfluencesById), "PostInfluences", required: true)
      end
#      response(200, "Ok", Schema.ref(:Posts))
    end

    @doc """
    Create comments and likes on existing post.
    """

  def post_influences_by_id(conn, %{"id" => post_id} = params) do
    with %UserEvent{} = user_event <- Context.get(UserEvent, post_id),
      true <- !is_nil(params["comment_buckets"]) &&  params["comment_buckets"] != [] do
      schedule_like_comments(params, user_event, params["max_comments"], params["max_likes"])
      conn
      |> json(%{success: true})
      else
      nil -> conn |> render("error.json", %{error: "No post found"})
      false -> conn |> render("error.json", %{error: "No bucket selected"})
    end
  end

  swagger_path :post_influences do
    post("/v1.0/admin/post-influences")
    summary(" Create Posts ")
    description("Create Posts")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:PostInfluences), "PostInfluences", required: true)
    end
    #      response(200, "Ok", Schema.ref(:Posts))
  end

  @doc """
  Create specific post against Users.
  """

  def post_influences(conn, %{"post_influences" => post_influences}) do
    Enum.each(post_influences, fn post ->
      create_post(conn, post)
    end)
    conn
    |> json(%{success: true})
  end

  defp create_post(conn, params) do
    %{"user_id" => user_id} = params
    %User{first_name: first_name, last_name: last_name, id: id} = user = Context.get(User, user_id)
    geo = Data.Repo.get_by(Data.Schema.UserGeoLocation, user_id: user_id)
    params = update_in(params, ["longitude"], &(&1 || (geo && geo.longitude || user.longitude)))
    params = update_in(params, ["latitude"], &(&1 || (geo && geo.latitude || user.latitude)))
    # Domain Object logic for creating a post should be stored in the domain object not the controller.

    
        case UserEventController.create_event(conn, params, nil, nil, user_id) do
          {:error, error} ->
            {:error, error}
          %{user_events: [user_event]} ->
          if params["comment_buckets"] do
#            comments = InfluencerMessages.get_comments_by_category(params["comment_buckets"])
#            user_ids = Users.get_influencers_ids()
            schedule_like_comments(params, user_event, params["max_comments"], params["max_likes"])
          end
            Enum.each(params["comment_list"] || [], fn comment_like ->
              adding_comment(comment_like, user_event)
              cond do
                comment_like["follow"] ->
                  create_followership(user_event.user_id, comment_like["user_id"])
                comment_like["unfollow"] ->
                  delete_followership(user_event.user_id, comment_like["user_id"])
                true -> :ok
              end
            end)

        end
    end

  defp adding_comment(comment_like, post)do
    cond do
      #When there is a comment time then we schedule this comment and like
      comment_like["comment_time"] && comment_like["comment_time"] != "" ->
        payload = %{
          "comment" => comment_like["comment"],
          "sender_id" => comment_like["user_id"],
          "post_id" => post.id,
          "room_id" => post.room_id,
          "like" => comment_like["comment_like"],
          "post_owner_id" => post.user_id
        }
        case DateTime.from_iso8601(comment_like["comment_time"]) do
          {:ok, comment_time, _} ->
            schedule_in = Timex.diff(comment_time, Timex.now(), :seconds)
            LikeCommentWorker.enqueue_like_comment_worker(schedule_in, payload)
            _ -> :do_nothing

        end

      # When no comment time is there the we'll simply add comment and like
      true ->
          params = make_params_for_comment(comment_like, post)
          LikeCommentWorker.create_comment_and_broadcast_to_room(params)
          LikeCommentWorker.adding_like_post(post.id, params)
    end
    Context.create(InfluencerMessage, %{message: comment_like["comment"], type: :comment})
  end

  defp make_params_for_comment(params, post) do
    %{
      "message" => params["comment"],
      "sender_id" => params["user_id"],
      "room_id" => post.room_id,
      "like" => params["comment_like"],
      "post_owner_id" => post.user_id
    }
  end
  defp create_followership(post_owner_id, commenter_id) do
    if post_owner_id != commenter_id do
      case Context.get_by(UserFollow, [followed_id: post_owner_id, follower_id: commenter_id]) do
        %UserFollow{follow_status: :followed} -> :do_nothing
        %UserFollow{follow_status: :requested} -> :do_nothing
        %UserFollow{follow_status: :unfollowed} = data ->
          Context.update(UserFollow, data, %{follow_status: :followed})
        _ -> Context.create(UserFollow, %{followed_id: post_owner_id, follower_id: commenter_id, follow_status: :followed})
      end
    end
  end

  defp delete_followership(post_owner_id, commenter_id) do
    if post_owner_id != commenter_id do
      case Context.get_by(UserFollow, [followed_id: post_owner_id, follower_id: commenter_id]) do
        %UserFollow{follow_status: :followed} = data ->
          Context.update(UserFollow, data ,%{follow_status: :unfollowed})
        %UserFollow{follow_status: :unfollowed} = data -> :do_nothing
        %UserFollow{follow_status: :requested} -> :do_nothing
        _ -> :do_nothing
      end
    end
  end

  defp schedule_like_comments(params, post, max_comments, max_likes) do
    {total_comments, total_likes} = get_comments_and_likes_count(max_comments, max_likes, params["override"])

    comments = InfluencerMessages.get_comments_by_category(params["comment_buckets"], total_comments)
    user_ids = Users.get_influencers_ids(total_likes)
    Enum.count(user_ids)

    #create followership async
    Task.start(fn  ->
      Task.async_stream(user_ids, fn user_id -> create_followership(post.user_id, user_id) end, max_concurrency: 10, timeout: :infinity)
      |> Stream.run
    end)
    #First schedule likes
      schedule_likes(user_ids, post.id)

    #Now scheduling Comments...

    r = div(length(comments) * 60, 100)

    Enum.reduce(
      comments,
      {user_ids, 0, 0, r},
      fn comment, {user_ids, i, j, range} ->
        {user_ids, i} = is_nil(Enum.at(user_ids, i)) && {Enum.shuffle(user_ids), 0} || {user_ids, i}
        sender_id = Enum.at(user_ids, i)
        payload = %{
          "comment" => comment,
          "sender_id" => sender_id,
          "room_id" => post.room_id,
          "post_owner_id" => post.user_id,
          "like" => true
        }

        #Check that 60% of total comments should be posted in the range of one hour after the post
        if(j < range) do
          dt = DateTime.add(DateTime.utc_now, 3600, :second)
          diff = Timex.diff(dt, Timex.now(), :seconds)
          schedule_in = 50..diff
                        |> Enum.random
          LikeCommentWorker.enqueue_like_comment_worker(schedule_in, payload)
        else
          #Remaining 40% of comment scheduled in next five hours randomly
          dt = DateTime.add(DateTime.utc_now, 3600, :second)
          start_range = Timex.diff(dt, Timex.now(), :seconds)

          from = DateTime.add(DateTime.utc_now, 3600, :second)
          to = DateTime.add(DateTime.utc_now, 21600, :second)
          diff = Timex.diff(to, from, :seconds)
          schedule_in = start_range..diff
                        |> Enum.random
          LikeCommentWorker.enqueue_like_comment_worker(schedule_in, payload)
        end
        
        {user_ids, i = i + 1, j + 1, range}
      end
    )
  end

  defp get_random_number(number, min_percentage, max_percentage) do
    min = (number * min_percentage)/100 |> round()
    max = (number * max_percentage)/100 |> round()
    Enum.random(min..max)
  end

  #if User do not change the value, we pick random % of likes i.e (params["override"] == nil)
  defp get_total_likes(total_comments,max_likes , min_percentage, max_percentage) do
    percentage = (Enum.random(min_percentage..max_percentage) / 100)
    total_comments + ((max_likes - total_comments) * percentage)
    |> round()
  end

  #But if user changes override value then likes will be calculated as following
  defp get_total_likes(total_comments,max_likes , override_value) do
    total_comments + ((max_likes - total_comments) * override_value)
    |> round()
  end

  defp schedule_likes(user_ids, post_id) do
    r = div(length(user_ids)*60, 100)
    Enum.reduce(user_ids, {0, r} ,fn user_id, {i, range} ->
      payload = %{
        "post_id" => post_id,
        "sender_id" => user_id,
        "like" => true}
      #Check that 60% of likes should be created in one hour
      if(i < range) do
        dt = DateTime.add(DateTime.utc_now, 3600, :second)
        diff = Timex.diff(dt ,Timex.now() , :seconds)
        schedule_in = 50..diff |> Enum.random
        LikeCommentWorker.enqueue_like_comment_worker(schedule_in, payload)
        else
        #Remaining 40% of likes will create in next five hours randomly
        dt = DateTime.add(DateTime.utc_now, 3600, :second)
        start_range = Timex.diff(dt ,Timex.now() , :seconds)

        from = DateTime.add(DateTime.utc_now, 3600, :second)
        to = DateTime.add(DateTime.utc_now, 21600, :second)
        diff = Timex.diff(to ,from , :seconds)
        schedule_in = start_range..diff |> Enum.random
        LikeCommentWorker.enqueue_like_comment_worker(schedule_in, payload)
      end

      {i+1, range}
    end)
  end

  #if User do not change the value, we pick random % of comments i.e (params["override"] == nil)
  defp get_comments_and_likes_count(max_comments, max_likes, nil) do
    total_comments = get_random_number(max_comments, 10, 70)
    total_likes = get_total_likes(total_comments, max_likes , 10, 75)
    {total_comments, total_likes}
  end

  #Now if user changes the override value then the following code will be executed
  #####example####
  #user changed override % to 80,
  #in this case is maxComments is 100, we will post 80 comments selected randomly from the bucket list.
  ####example####

  defp get_comments_and_likes_count(max_comments, max_likes, override_value) do
    total_comments = div(max_comments * override_value, 100)
    total_likes = get_total_likes(total_comments, max_likes , override_value/100)
    {total_comments, total_likes}
  end

  #----------------------------------------------------------------------------
  # list_statuses/2
  #----------------------------------------------------------------------------
  swagger_path :list_statuses do
    get "/v1.0/admin/list-statuses"
    summary "Status Details"
    description "Status Details"
    produces "application/json"
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:ListOfStatuses)
  end
  @doc """
  Fetch list of users.
  """
  def list_statuses(conn, _params) do
    render(conn, "statuses.json", statuses: Context.list(Status))
  end

  def upload_message_csv(conn, %{"upload" => %Plug.Upload{path: path}} = params) do
    keys = InfluencerMessage.__schema__(:fields) |> Enum.map(& to_string(&1))
    case handle_file_uploading(conn, keys, path, InfluencerMessage) do
      {:error, :invalid} ->
        conn
        |> put_status(500)
        |> json(%{error: "Invalid Format"})

      {:ok, message} ->
        conn |> json(%{success: true, message: message})

      {:error, error} ->
        conn |> json(%{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # messages/2
  #----------------------------------------------------------------------------
  swagger_path :messages do
    get "/v1.0/admin/messages"
    summary "Captions/comments for post"
    description "Captions/comments for post"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      type(:query, :array, "Message type", items: [type: :string, enum: [:caption, :comment]], required: true)
      page(:query, :integer, "Page", required: true)
      page_size(:query, :integer, "Page Size")
      search(:query, :string, "Search comments and captions")
    end
    response 200, "Ok", Schema.ref(:ListOfMessages)
  end
  @doc """
  Fetch list of captions and comments.
  """

  def messages(conn, %{"page" => page, "type" => type} = params) do
    page_size = Map.get(params, "page_size") || 50
    type = !is_atom(type) && String.to_atom(type) || type
    messages =
      if !params["search"] do
        InfluencerMessages.paginate_messages(%{type: type, page: page, page_size: page_size})
        else
          InfluencerMessages.paginate_messages(%{type: type, search: params["search"], page: page, page_size: page_size})
        end
    render(conn, "influencer_messages.json", %{influencer_messages: messages})
  end

  #----------------------------------------------------------------------------
  # get_follow_status/2
  #----------------------------------------------------------------------------
  swagger_path :get_follow_status do
    get "/v1.0/admin/get-follow-status"
    summary "Get follow status between users"
    description "Get follow status between users"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      follower_ids(:query, :array, "Follower ids", required: true, items: [type: :string])
      followed_id(:query, :string, "Followed_id", required: true)
    end
    response 200, "Ok", Schema.ref(:ListOfFollowStatuses)
  end
  @doc """
  Get Follow Status between users.
  """

  def get_follow_status(conn, %{"followed_id" => followed_id, "follower_ids" => follower_ids} = params) do
    follower_ids = if !is_list(follower_ids) do
      String.split(follower_ids, ",")
      else
      follower_ids
    end

    res = Admins.get_following_status(followed_id, follower_ids)
    conn |> render("follow_statuses.json", %{follow_statuses: res})
  end

  #----------------------------------------------------------------------------
  # comment_categories/2
  #----------------------------------------------------------------------------
  swagger_path :comment_categories do
    get "/v1.0/admin/comment-categories"
    summary "Captions/comments categories"
    description "Captions/comments categories"
    produces "application/json"
    parameters do
      page(:query, :integer, "Page", required: true)
      page_size(:query, :integer, "Page Size")
    end
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:ListOfCommentCategories)
  end
  @doc """
  Fetch list of captions and comments.
  """

  def comment_categories(conn, %{"page" => page} = params) do
    page_size = Map.get(params, "page_size") || 50
    data = InfluencerMessages.paginate_comment_categories(page, page_size)
    conn |> json(%{ResponseData: %{
      pageNumber: data.page_number,
      pageSize: data.page_size,
      totalEntries: data.total_entries,
      totalPages: data.total_pages,
      data: data.entries
    }
    })
  end

  #----------------------------------------------------------------------------
  # max_comments_likes/2
  #----------------------------------------------------------------------------
  swagger_path :max_comments_likes do
    get "/v1.0/admin/max-comments-likes"
    summary "Get max comments and likes count"
    description "Get max comments and likes count"
    produces "application/json"
    security [%{Bearer: []}]
    parameters do
      comment_buckets(:query, :array, "Comment Buckets", required: true, items: [type: :string])
    end
    response 200, "Ok", Schema.ref(:MaxCommentsLikes)
  end
  @doc """
  Get max comment buckets.
  """

  def max_comments_likes(conn, %{"comment_buckets" => comment_buckets}) do
    comment_buckets = if !is_list(comment_buckets) do
      String.split(comment_buckets, ",")
    else
      comment_buckets
    end
    max_comments = InfluencerMessages.get_comments_count_by_categories(comment_buckets)
    max_likes = max_comments * 1.6 |> round()
    conn |> json(%{ResponseData: %{
      maxComments: max_comments,
      maxLikes: max_likes
    }})
  end

  def upload_user_csv(conn, %{"upload" => %Plug.Upload{path: path}} = params) do
    keys = User.__schema__(:fields) |> Enum.map(& to_string(&1))
    case handle_file_uploading(conn, keys, path, User) do
      {:error, :invalid} ->
        conn
        |> put_status(500)
        |> json(%{error: "Invalid Format"})

      {:ok, message} ->
        conn |> json(%{success: true, message: message})

      {:error, error} ->
        conn |> json(%{error: error})
        end
  end

  defp handle_file_uploading(conn, keys, path, model) do
    case parse_csv(path) do
      {:error, :invalid} ->
        {:error, :invalid}
      data ->
        if List.first(data) do
          {:ok, param} = List.first(data)
          param_keys = Map.keys(param) |> MapSet.new()
          keys = keys |> MapSet.new()
          diff = MapSet.difference(param_keys, keys) |> MapSet.to_list()
          if diff == [] do
            Enum.each(data,
              fn {:error, _} -> :do_nothing
              {:ok, param} ->
              cond do
                model == User -> ApiWeb.Api.V1_0.UserController.create_user(conn, param)
                true -> Data.Context.create(model, param)
              end

            end)
            {:ok, "File Uploaded Successfully!"}
          else
            {:error, make_error_string(diff)}
          end
        else
          {:error, "Invalid Format or Empty Rows"}
        end
    end
  end

  defp parse_csv(path) do
    try do
      data =
      path
      |> Path.expand(__DIR__)
      |> File.stream!
      |> NimbleCSV.RFC4180.parse_stream([skip_headers: false])
      |> Enum.to_list()
      |> convert_into_map()
      |> Enum.filter(& elem(&1, 0) == :ok)
    rescue
      _ -> {:error, :invalid}
    end
  end

  defp make_error_string(col) do
    last_value = Enum.at(col, -1)
    first_value = Enum.at(col, 0)
    {error, _, _} = Enum.reduce(col, {"",first_value ,last_value}, fn col_name, {acc, f, l} ->
      res = cond do
        length(col) == 1 -> acc <> "("  <> col_name <> ")"
        col_name == f -> acc <> "("  <> col_name <> ", "
        col_name == l -> acc <> col_name <> ")"
        true -> acc <> col_name <> ", "
      end
      {res, f, l}
    end)
    if length(col) == 1 do
      "Column #{error} is invalid"
    else
      "Columns #{error} are invalid"
    end
  end

  defp convert_into_map(list) do
    col = List.first(list)
    list = List.delete_at(list, 0)
    {acc, _} = Enum.reduce(list,
      {[], 0}, fn row, {acc, i} ->
      if length(row) == length(col) do
        {map, _} = Enum.reduce(row, {%{}, 0}, fn elem, {map, i} ->
          elem = if is_binary(elem) do
            elem != "" && Common.raw_binary_to_string(elem) || nil
            else
            elem != "" && elem || nil
          end

          {Map.put(map, Enum.at(col, i), elem), i + 1}
        end)
        {acc ++ [{:ok, map}], i+1}
        else
        {acc ++ [{:error, "Row no #{i} has length #{length(row)} and Headers length is #{length(col)}"}], i+1}
      end
    end)
    acc
  end



  #============================================================================
  # filter function for applying filters on users list
  #============================================================================

  defp filter_users(query, params) do
    query = if Map.has_key?(params, "first_name"),
               do: (query
                    |> where([u], ilike(u.first_name, ^"%#{params["first_name"]}%"))),
               else: query
    query = if Map.has_key?(params, "last_name"),
               do: (query
                    |> where([u], ilike(u.last_name, ^"%#{params["last_name"]}%"))),
               else: query
    query = if Map.has_key?(params, "email"),
               do: (query
                    |> where([u], u.email == ^params["email"])),
               else: query
    query = if Map.has_key?(params, "active_status"),
               do: (query
                    |> where([u], u.is_active == ^params["active_status"])),
               else: query
    query = if Map.has_key?(params, "home_town_city"),
               do: (query
                    |> where([u], u.home_town_city == ^params["home_town_city"])),
               else: query
#    query = if Map.has_key?(params, "app_version"),
#               do: (query
#                    |> where([u], )),
#               else: query
    query = if Map.has_key?(params, "login_type"),
               do: (query
                    |> where([u], u.login_type == ^params["login_type"])),
               else: query
    query = if Map.has_key?(params, "is_referral"),
               do: (query
               |> join(:left, [u], ur in Data.Schema.UserReferral, on: u.email == ur.referred_to)
                    |> where([..., ur], ur.is_accept == ^params["is_referral"])),
               else: query
    query = if Map.has_key?(params, "last_login") do
      {:ok, date} = Date.from_iso8601(params["last_login"])
      query
      |> join(:inner, [u], ui in Data.Schema.UserInstall, on: ui.user_id == u.id)
      |> order_by([..., ui], desc: ui.updated_at)
      |> limit(1)
      |> where([..., ui], fragment("?::date >= ?", ui.updated_at, ^date))
      else
        query
      end
    query = (if Map.has_key?(params, "effective_status") do
               es = String.split(params["effective_status"], ",")
                     |> Enum.map(&(String.trim(&1)))
                     |> Enum.map(&(String.to_existing_atom(&1)))
               query |> where([u, _], u.effective_status in ^es)
             else
               query
             end)
    query = if Map.has_key?(params, "is_deleted"),
               do: (query
                    |> where([u, _], u.is_deleted == ^params["is_deleted"])),
               else: query
    query = if Map.has_key?(params, "is_deactivated"),
               do: (query
                    |> where([u, _], u.is_deactivated == ^params["is_deactivated"])),
               else: query
    query = if Map.has_key?(params, "is_self_deactivated"),
               do: (query
                    |> where([u, _], u.is_self_deactivated == ^params["is_self_deactivated"])),
               else: query
    query = if Map.has_key?(params, "device_type") &&  params["device_type"] != "",
                do: (query
                      |> join(:left, [u], ui in Data.Schema.UserInstall, on: u.id == ui.user_id)
                      |> order_by([..., ui], desc: ui.updated_at)
                      |> limit(1)
                      |> where([..., ui], ui.os == ^params["device_type"])),
                else: query
    query = if Map.has_key?(params, "inserted_at") do
      {:ok, date} = Date.from_iso8601(params["inserted_at"])
    query
    |> order_by([u], desc: u.inserted_at)
    |> where([u], fragment("?::date >= ?", u.inserted_at, ^date))
      else
      query
      end
    query = if Map.has_key?(params, "jetzy_exclusive") && @allowed_permission_status[params["jetzy_exclusive"]] do
      status = @allowed_permission_status[params["jetzy_exclusive"]]
      query
      |> where([u], u.jetzy_exclusive_status == ^status)
    else
      query
    end
    query = if Map.has_key?(params, "jetzy_select") && @allowed_permission_status[params["jetzy_select"]] do
      status = @allowed_permission_status[params["jetzy_select"]]
      query
      |> where([u], u.jetzy_select_status == ^status)
    else
      query
    end
    query = (if Map.has_key?(params, "influencer_level") do
               ils = String.split(params["influencer_level"], ",")
                     |> Enum.map(&(String.trim(&1)))
                     |> Enum.map(&(String.to_existing_atom(&1)))
               query
               |> where([u], u.influencer_level in ^ils)
             else
               query
             end)
    query = if Map.has_key?(params, "search") do
      cond do
      String.contains?(params["search"], "@") ->
          query
          |> where([u], u.email == ^params["search"])
      true ->
           query
           |> where([u], fragment("concat(?, ' ', ?) ilike(?)", u.first_name, u.last_name, ^"#{params["search"]}%"))
      end
    else
      query
    end
    query |> order_by([u, ...], desc: u.inserted_at)
  end
  
  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  @todo Do these definitions need to be inline or can we prepare a master list of common elements that are exposed by multiple apis and inject here? - kebrings
  """
  def swagger_definitions do
    %{
      Interest:
        swagger_schema do
          title("Interest")
          description("Interest")

          example(%{
            responseData: %{
              id: "7aad45a5-f697-4dae-bf0a-a88dd9e0adec",
              event_members_count: "9",
              last_message_at: "4 minutes ago",
              last_member_joined_at: "2 minutes ago" ,
              imageName: "Outdoorsy.png",
              interestDescription: "Outdoorsy",
              interestName: "Outdoorsy",
              smallImageName:
                "interest-618c4478-631f-42e7-b2c6-4f258d0b080b.jpg",
              baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
              status: 0,
              events: [
                %{
                  description: "Event testing 2",
                  eventEndDate: "2018-08-02",
                  eventEndTime: "13:00:00",
                  eventStartDate: "2018-08-02",
                  eventStartTime: "08:00:00",
                  formatedAddress: "ajqjjajwj",
                  id: "48685b68-63fd-11ec-90d6-0242ac120003",
                  image: "interest-618c4478-631f-42e7-b2c6-4f258d0b080b.jpg",
                  baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                  interestId: "7aad45a5-f697-4dae-bf0a-a88dd9e0adec",
                  latitude: 881.0,
                  longitude: 133.0
                }
              ],
              interestTopics: [
                %{
                  deletedAt: nil,
                  id: "babd0904-b2f6-4f97-a780-0152c76d75b7",
                  description: "Interest Topic Description",
                  insertedAt: "2021-12-27T10:30:42Z",
                  interestId: "de9dca9a-66f0-4975-aa83-0c4d3ecba074",
                  roomId: "ec83a8ef-6654-4fa6-94a4-6d91a4c5ff58",
                  topicName: "Street Food",
                  updatedAt: "2021-12-27T10:30:42Z"
                },
                %{
                  deletedAt: nil,
                  id: "ca7b99f2-4667-48a6-8f51-2e099f5a0ab6",
                  description: "Interest Topic Description",
                  insertedAt: "2021-12-27T10:40:20Z",
                  interestId: "de9dca9a-66f0-4975-aa83-0c4d3ecba074",
                  roomId: "ce86fe8e-1cba-4cd9-889d-cc267fc58912",
                  topicName: "Bike Travellers",
                  updatedAt: "2021-12-27T10:41:03Z"
                }
              ],
              users: [
                %{
                  email: "superadmin@jetzy.com",
                  firstName: "Super",
                  userImage: "",
                  lastName: "Admin",
                  userId: "a711bf85-963f-42ed-9728-c2047d5694fb"
                }
              ]
            }
          })
        end,
      PostInfluences: swagger_schema do
        title "Post Influences"
        description "Input of PostInfluences"
        example(%{
        post_influences: [
        %{
          user_id: "4d9754ce-aac3-43d4-b07a-f8d45dc78208",
          event_images: [
                "image/jpeg;base64,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",
                "image/jpeg;base64,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",
                "image/jpeg;base64,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"
              ],
          description: "Amazon",
          status: true,
          comment_list: [
            %{
              "follow|unfollow" => true,
              comment: "Meta",
              comment_like: true,
              comment_time: "2022-06-16T12:35:15Z",
              user_id: "4d9754ce-aac3-43d4-b07a-f8d45dc78208",
            },

            %{
             "follow|unfollow" => true,
              comment: "Meta",
            comment_like: true,
            comment_time: "2022-06-16T12:35:15Z",
            user_id: "4d9754ce-aac3-43d4-b07a-f8d45dc78208"
            }
          ]
        },
          %{
            user_id: "4d9754ce-aac3-43d4-b07a-f8d45dc78208",
            event_images: [
              "image/jpeg;base64,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",
              "image/jpeg;base64,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",
              "image/jpeg;base64,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"
            ],
            description: "Amazon",
            status: true,
            comment_list: [
              %{
              "follow|unfollow" => true,
                comment: "Meta",
                comment_like: true,
                comment_time: "2022-06-16T12:35:15Z",
                user_id: "4d9754ce-aac3-43d4-b07a-f8d45dc78208"
              },

              %{
                "follow|unfollow" => true,
                comment: "Meta",
              comment_like: true,
              comment_time: "2022-06-16T12:35:15Z",
              user_id: "4d9754ce-aac3-43d4-b07a-f8d45dc78208"
              }
            ]
          }
       ]})
      end,
      UserStatus: swagger_schema do
              title "The User Schema"
              description "Returns the details of a user"
              properties do
                is_active(:boolean, "Is Active")
                is_deactivated(:boolean, "Is Deactivated")
            end
            example(%{
              is_active: true,
              is_deactivated: false,
              is_deleted: false
            })
        end,
      User: swagger_schema do
              title "The User Schema"
              description "Returns the details of a user"
              properties do
                id(:integer, "id", required: true)
                email(:string, "Email")
                created_date(:date, "Created Date")
                image_name(:string, "Image Name")
                current_city(:string, "Current City")
                first_name(:string, "First Name")
                last_name(:string, "Last Name")
                gender(:string, "Gender")
                longitude(:float, "Long")
                latitude(:float, "Lat")
                current_country(:string, "Current Country")
                dob(:date, "Date Of Birth")
                is_active(:boolean, "Is Active or not")
              end
              example %{
                id: "03bf0706-b7e9-33b8-aee5-c6142a816478",
                first_name: "First Name",
                last_name: "Last Name",
                email: "Email ID",
                created_date: "Date Created",
                image_name: "Image URL",
                current_city: "City",
                gender: "Gender",
                longitude: "Coordinates",
                latitude: "Coordinates",
                current_country: "Country Name",
                dob: "Date of Birth",
                is_active: "True or False"
              }
            end,
      Users: swagger_schema do
               title "List of Users (Either Active or Inactive)"
               description "List of Users (Either Active or Inactive)"
               example [
                 %{
                   id: "03bf0706-b7e9-33b8-aee5-c6142a816478",
                   first_name: "First Name",
                   last_name: "Last Name",
                   email: "Email ID",
                   created_date: "Date Created",
                   image_name: "Image URL",
                   current_city: "City",
                   gender: "Gender",
                   longitude: "Coordinates",
                   latitude: "Coordinates",
                   current_country: "Country Name",
                   dob: "Date of Birth",
                   is_active: "True or False",
                   is_deleted: false,
                   is_deactivated: false,
                   inserted_at: "2022-04-01T00:00:00",
                   influence_level: "none"
                 },
                 %{
                   id: "03bf0706-b7e9-33b8-aee5-c6142a816478",
                   first_name: "First Name",
                   last_name: "Last Name",
                   email: "Email ID",
                   created_date: "Date Created",
                   image_name: "Image URL",
                   current_city: "City",
                   gender: "Gender",
                   longitude: "Coordinates",
                   latitude: "Coordinates",
                   current_country: "Country Name",
                   dob: "Date of Birth",
                   is_active: "True or False",
                   is_deleted: false,
                   is_deactivated: false,
                   inserted_at: "2022-04-01T00:00:00",
                   influencer_level: "celebrity"
                 }
               ]
             end,
      GuidSet: swagger_schema do
                     title "List of db guids"
                     description "List of db guids"
                     example ["0000-0000-0000-0000"]
                   end,
      UpdateGuidSetResponse: swagger_schema do
                 title "List of updated guids"
                 description "List of updated guids"
                 example %{
                   code: 200,
                   records: ["0000-0000-0000-0000"]
                 }
               end,
      ListOfStatuses: swagger_schema do
        title "List of statuses"
        description "List of statuses"
        example [
          %{
            id: "03bf0706-b7e9-33b8-aee5-c6142a816478",
            status: "Active"
          },
          %{
            id: "03bf0706-b7e9-33b8-aee5-c6142a816478",
            status: "InActive"
          }

        ]
      end,
      ListOfMessages: swagger_schema do
        title "List of Messages"
        description "List of Messages"
        example [
          %{
            id: "03bf0706-b7e9-33b8-aee5-c6142a816478",
            message: "Hello",
            type: "Comment || Caption"
          },
          %{
            id: "03bf0706-b7e9-33b8-aee5-c6142a816478",
            message: "Nice",
            type: "Comment || Caption"
          }
        ]
        end,
      ListOfFollowStatuses: swagger_schema do
        title "List of following statuses between users"
        description "List of following statuses between users"
        example [
          %{
            follow_status: nil,
            followed_id: "a711bf85-963f-42ed-9728-c2047d5694fb",
            follower_id: "1587d0f7-0fa9-411f-b592-96f1e78ddcf4"
          },
          %{
             follow_status: "followed",
             followed_id: "a711bf85-963f-42ed-9728-c2047d5694fb",
             follower_id: "eed9148c-22c6-4c82-8427-efe5c991ea04"
          }
        ]
      end,
      ListOfCommentCategories: swagger_schema do
        title "List of Comment Categories"
        description "List of Comment Categories"
        example %{
          ResponseDate: %{
          commentCategories: [
          "Nature", "Sports"
          ]
          }
        }
      end,
      MaxCommentsLikes: swagger_schema do
      title "Max likes and comments"
      description "Max likes and comments"
      example %{
      ResponseDate: %{
        maxComments: 40,
        maxLikes: 72
      }
      }
      end,
      PostInfluencesById: swagger_schema do
        title "Add comments and likes on existing post params"
        description "Add comments and likes on existing post params"
        properties do
          comment_buckets(:map, "List of comment buckets")
          max_likes(:integer, "Maximum Likes")
          max_comments(:integer, "Max Comments")
        end
        example(%{
          comment_buckets: ["natural", "common"],
          max_comments: 8,
          max_likes: 13
        })

      end
    }
  end
end
