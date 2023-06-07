#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.InterestController do
#  @moduledoc """
#  Manage Authenticated and Guest User Interests and user interest related queries.
#  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use PhoenixSwagger
  alias Data.Repo

  alias Data.Context
  import Ecto.Multi
  alias Data.Context.{Users, InterestTopics, UserEvents, UserInterests, Interests, UserEvents, UserBlocks, NotificationsRecords}
  alias Data.Schema.{UserInterestMeta,Interest, UserInterest, User}
  #  alias Data.Schema.{UserEvent, UserInstall, GuestInterest}
  alias JetzyModule.AssetStoreModule, as: AssetStore
  alias SecureX.UserRoles
  alias ApiWeb.Utils.Common

  @template_name  "notification_email.html"

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # accept_interest_request/2
  #----------------------------------------------------------------------------
  swagger_path :accept_interest_request do
    post("/accept-interest-request")
    summary("Accept interest request")
    description("Accept interest request")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      status(:query,  :array, "Accept OR Reject", required: true,
      items: [type: :string, enum: ["accept", "reject"]])
      id(:query, :string, "Interest ID", required: true)
    end
    response(200, "Ok", Schema.ref(:AcceptInterest))
  end

  @doc """
  List or filter interests with Guest Level Authentication
  """
  def accept_interest_request(conn, %{"id" => id, "status" => status}) when id != "" and status != "" do
    %{id: user_id, first_name: first_name, last_name: last_name} = Api.Guardian.Plug.current_resource(conn)
    with %UserInterest{status: :pending} = user_interest <- Context.get_by(UserInterest, [user_id: user_id, interest_id: id]),
    %UserInterestMeta{} = user_interest_meta <- Context.get_by(UserInterestMeta, [interest_id: id]),
    {:ok, user_interest_meta} <- Context.update(UserInterestMeta, user_interest_meta, %{total_members: user_interest_meta.total_members + 1})
    do
      %{created_by_id: created_by_id, interest_name: interest_name} = Context.get(Interest, id)
      push_notification_params = %{
        "keys" => %{
          "first_name" => first_name,
           "last_name" => last_name,
          "interest_name" => interest_name
        },
        "event" => "accept_interest",
        "type" => "accept_interest",
        "template_name" => @template_name,
        "sender_id" => user_id,
        "resource_id" => id,
        "owner_id" => created_by_id,
        "user_id" => created_by_id
      }
      interest = case status do
        "accept" ->
          %{status: :accepted}
        "reject" ->
          %{status: :rejected}
        _ ->
          %{status: :pending}
      end
      {:ok, interest} =  Context.update(UserInterest, user_interest, interest)

      # delete existing invite request
      ApiWeb.Utils.PushNotification.soft_delete_push_notification(created_by_id, user_id, ["interest_invite"])

      if status == "accept" do
        ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params)
      end
      render(conn, "interest.json", %{user_interest: interest})
    else
      %UserInterest{status: :cancelled}-> render(conn, "interest.json", %{error: "The request was not found."})
      %UserInterest{status: :accepted} -> render(conn, "interest.json", %{error: "Already Following the Interest"})
     _ -> render(conn, "interest.json", %{error: "No data found for this interest and user ID"})
    end
  end
  def accept_interest_request(conn, %{"id" => _id, "status" => _status}) do
    render(conn, "interest.json", %{error: "Please enter interest ID and status"})
  end

  defp update_status(conn, status, user_interest) do
    interest = case status do
      "accept" ->
        %{status: :accepted}
      "reject" ->
        %{status: :rejected}
      _ ->
        %{status: :pending}
    end
    {:ok, interest} =  Context.update(UserInterest, user_interest, interest)
    render(conn, "interest.json", %{user_interest: interest})
  end

  #----------------------------------------------------------------------------
  # index_for_guest/2
  #----------------------------------------------------------------------------
  swagger_path :index_for_guest do
    get("/v1.0/guest/interests")
    summary("Get List OF Interests")
    description("Get List OF Interests")
    produces("application/json")
    parameters do
      page(:query, :integer, "Page no.", required: true)
      search(:query, :string, "Search")
    end
    response(200, "Ok", Schema.ref(:ListInterest))
  end
  @doc """
  List or filter interests with Guest Level Authentication
  """
  def index_for_guest(conn, %{"page" => page, "search" => search}) do
    interests = Interests.get_interests_list_for_guest_with_search(page, search)
    render(conn, "interests.json", %{interests: interests})
  end
  def index_for_guest(conn, %{"page" => page}) do
    interests = Interests.get_interests_list_for_guest(page)
    render(conn, "interests.json", %{interests: interests})
  end

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get("/v1.0/interests")
    summary("Get List OF Interests")
    description("Get List OF Interests")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      page(:query, :integer, "Page no.", required: true)
      search(:query, :string, "Search")
    end
    response(200, "Ok", Schema.ref(:ListInterest))
  end
  @doc """
  List or filter interests
  """
  def index(conn, %{"page" => page, "search" => search}) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    render(conn, "interests.json",
      %{interests: Interests.get_interests_list_with_search(user_id, search, page), current_user_id: user_id})
  end
  def index(conn, %{"page" => page}) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    render(conn, "interests.json", %{interests: Interests.get_interests_list(user_id, page), current_user_id: user_id})
  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get("/v1.0/interests/{id}")
    summary("Get Interests By ID")
    description("Get Interests By ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Interests ID", required: true)
    end

    response(200, "Ok", Schema.ref(:Interest))
  end
  @doc """
  Get interest by id
  """
  def show(conn, %{"id" => id}) do
    %{id: user_id, latitude: lat, longitude: long} = Api.Guardian.Plug.current_resource(conn)
    with %Interest{} = interest <- Context.get(Interest, id) do
      interest_users = Users.get_interest_users_sort_by_location_and_friends(
        %{interest_id: interest.id, user_id: user_id, lat: lat, long: long, page: 1})
      interest_events = UserEvents.get_nearby_events_by_interest_id(
        %{user_id: user_id, interest_id: interest.id, lat: lat, long: long, page: 1})
      interest =
        interest
        |> Map.put(:interest_users, interest_users.entries)
        |> Map.put(:interest_events, interest_events.entries)
        |> Map.put(:user_id, user_id)
      render(conn, "show.json", %{interest: interest, current_user_id: user_id})
    else
      nil -> render(conn, "interest.json", %{error: ["Interest does not exist"]})
    end
  end


  #----------------------------------------------------------------------------
  # private interest list user/2
  #----------------------------------------------------------------------------
  swagger_path :private_user_interest_list do
    get("/v1.0/private-user-interest")
    summary("Get Private Interests By ID")
    description("Get Private Interests By ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      page(:query, :integer, "Page no.", required: true)
      status(:query,  :array, "Add Status", required: true,
        items: [type: :string, enum: [ "pending", "accepted", "cancelled", "rejected", "blocked"]])
    end
    response(200, "Ok", Schema.ref(:ListInterest))
  end
  @doc """
  Get Private interest by id
  """
  def private_user_interest_list(conn, %{"page" =>  page, "status" => status}) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    case Interests.get_user_private_interest_list(user_id, status, page) do
      interests -> render(conn, "private_interests.json", %{interests: interests})
    end
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post("/v1.0/interests")
    summary("Create Interests")
    description("It will Create a new Interests.")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:CreateInterest), "Create Interest params", required: true)
    end

    response(200, "Ok", Schema.ref(:Interest))
  end
  @doc """
  Create new interest
  """
  def create(conn, params) do
    %User{} = user = Guardian.Plug.current_resource(conn)
    {:ok, user_roles} = UserRoles.get(%{user_id: user.id})
    if Interests.is_already_exist_interest_name(params["interest_name"]) == true do
        render(conn, "message.json", %{message: "Interest Name already exsist"})
    else
      params = Map.put(params, "created_by_id", user.id)

      params = unless Map.has_key?(params, "is_private") do
        Map.put(params, "is_private", false)
      else
        params
      end

      params = if Enum.at(user_roles, 0) !== "admin" and Map.get(params, "is_private") === false do
        complete_name = user.first_name <> " " <> user.last_name
        interest_name = Map.get(params, "interest_name")
        interest_email_params = %{
          template_name: "notification_email.html",
          notification: "#{complete_name}has created a new #{interest_name} interest. He requested for this interest to be public"
        }
        Api.Mailer.send_interest_public_email(interest_email_params)
        Map.replace(params, "is_private", true)
      else
        params
      end

      case create_sage(conn, params) do
        {:ok, %{interest: interest}} ->
          render(conn, "interest.json", %{interest: Data.Context.preload_selective(interest, :user_interest_meta), current_user_id: user.id})
        {:error, error} -> render(conn, "interest.json", %{error: error})
      end
    end
  end


  #----------------------------------------------------------------------------
  # send_interest_invite/2
  #----------------------------------------------------------------------------

  swagger_path :send_interest_invite do
  post("/interest-invite")
  summary("Invite to follow an interest")
  description("Invite a User to follow an interest.")
  produces("application/json")
  security([%{Bearer: []}])

  parameters do
    body(:body, Schema.ref(:InviteUserInterest), "Invite to follow an interest params", required: true)
  end

  response(200, "Ok", Schema.ref(:InterestInvite))
  end

  def send_interest_invite(conn, %{"users" => user_ids, "interest_id" => interest_id, "status" => "request"} = _params) do
    current_user = Api.Guardian.Plug.current_resource(conn)
    blocked_user_ids = UserBlocks.get_blocked_user_ids(current_user.id)
#    push_notification_params = %{
#      "keys" => %{
#        "first_name" => current_user.first_name
#      },
#      "event" => "interest_invite",
#      "template_name" => @template_name,
#      "sender_id" => current_user.id,
#      "resource_id" => interest_id,
#      "owner_id" => current_user.id
#    }
    case Context.get_by(Interest, [id: interest_id, created_by_id: current_user.id, is_private: true]) do
      %{} = interest -> result = Enum.reduce(user_ids, [],  fn user_id, acc ->
            with %{is_deleted: is_deleted, is_deactivated: is_deactivated, is_self_deactivated: is_self_deactivated} = _user <- Context.get(User, user_id),
                 false <- is_deleted or is_deactivated or is_self_deactivated,
                 false <- user_id in blocked_user_ids,
                 nil <- Context.get_by(UserInterest, [user_id: user_id, interest_id: interest_id]),
                 {:ok, data} <- Context.create(UserInterest,
                   %{interest_id: interest_id, user_id: user_id, status: :pending}) do
                  acc ++ [user_id]
              else
                %{status: :rejected} = user_interest -> {:ok, data} = Context.update(UserInterest, user_interest,
                  %{interest_id: interest_id, user_id: user_id, status: :pending})
                  acc ++ [user_id]
                _ -> acc
            end
          end)
             skipped = user_ids -- result
             push_notification_params = %{
               "keys" => %{
                 "first_name" => current_user.first_name, "last_name" => current_user.last_name,
                 "interest_name" => interest.interest_name
               },
               "event" => "interest_invite",
               "template_name" => @template_name,
               "sender_id" => current_user.id,
               "resource_id" => interest_id,
               "owner_id" => current_user.id
             }
              if result != [] do
                # delete invite request if already sent to user
                ApiWeb.Utils.PushNotification.soft_delete_push_notification(current_user.id, result, ["interest_invite"])
                ApiWeb.Utils.PushNotification.send_push_to_users(result, push_notification_params)
             end
             render(conn, "interest.json", %{successful: result, skipped: skipped})
      nil -> render(conn, "interest.json", %{error: "Record Not Found"})
      _ -> render(conn, "interest.json", %{error: "Something went wrong."})
    end
  end
  def send_interest_invite(conn, %{"users" => user_ids, "interest_id" => interest_id, "status" => "cancel"} = _params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    with %Interest{} = _interest <- Context.get_by(Interest, [id: interest_id, created_by_id: current_user_id, is_private: true]) do
      result = Enum.reduce(user_ids, [], fn user_id, acc ->
        with %{} = user_interest <- Context.get_by(UserInterest, [user_id: user_id, status: :pending]),
             {:ok, data} <- Context.update(UserInterest, user_interest,
               %{interest_id: interest_id, user_id: user_id, status: :cancelled}) do
          acc ++ [data.user_id]
        else
          _ -> acc
        end
      end)
      skipped = user_ids -- result
      render(conn, "interest.json", %{successful: result, skipped: skipped})
    else
      nil ->  render(conn, "interest.json", %{error: "This interest is not private or may not exist"})
      _ -> render(conn, "interest.json", %{error: "Something went wrong."})
    end
  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put("/v1.0/interests/{id}")
    summary("Update Interest")
    description("Update Interest")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Interest ID", required: true)
      body(:body, Schema.ref(:UpdateInterest), "Update Interest Params", required: true)
    end

    response(200, "Ok", Schema.ref(:Interest))
  end
  @doc """
  Update interest.
  """
  def update(conn, %{"id" => id} = params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    with %Interest{} = interest <- Context.get(Interest, id),
      params <- check_public_interest(interest, params),
         image <- AssetStore.upload_if_image_with_thumbnail(params, "image_name", "interest"),
         params <- (if is_tuple(image), do: Map.merge(params, %{"image_name" => elem(image, 0), "small_image_name" => elem(image, 1)}), else: params),
      {:ok, %Interest{} = interest} <- Context.update(Interest, interest, params) do
      render(conn, "interest.json", %{interest: interest, current_user_id: user_id})
    else
      nil -> render(conn, "interest.json", %{error: ["Interest not found"]})
      {:error, error} -> render(conn, "interest.json", %{error: error})
    end
  end

  # Handle private interest to be public while updating
  defp check_public_interest(interest, params) do
    params = if interest.is_private == false and Map.get(params, "is_private") == false do
      params
    else
      Map.replace(params, "is_private", true)
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete("/v1.0/interests/{id}")
    summary("Delete Interests")
    description("Delete Interest")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Interest ID", required: true)
    end

    response(200, "Ok", Schema.ref(:Interest))
  end
  @doc """
  Delete interest.
  """
  def delete(conn, %{"id" => id} = _params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    with %Interest{} = interest <- Context.get(Interest, id),
         {:ok, %Interest{} = interest} <- Context.delete(interest) do
      Task.async(NotificationsRecords, :delete_notification_by_resource_id, [interest.id])
      render(conn, "interest.json", %{interest: interest, current_user_id: user_id})
    else
      nil -> render(conn, "interest.json", %{error: ["Interest not found"]})
      {:error, error} -> render(conn, "interest.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # user_interests_list/2
  #----------------------------------------------------------------------------
  swagger_path :user_interests_list do
    get("/v1.0/user-interests")
    summary("Get List OF User Interests IDs")
    description("Get List OF User Interests IDs")
    produces("application/json")
    security([%{Bearer: []}])
    response(200, "Ok", Schema.ref(:ListUserInterest))
  end
  @doc """
  Get user's interests.
  """
  def user_interests_list(conn, _) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    interests = UserInterests.get_user_interests_list(user_id)

    render(conn, "user_interests_list.json", %{
      interest_list: Enum.map(interests, fn i -> i.interest_id end)
    })
  end

  #----------------------------------------------------------------------------
  # save_user_interests/2
  #----------------------------------------------------------------------------
  swagger_path :save_user_interests do
    post("/v1.0/user-interests")
    summary("Create User Interests")
    description("It will Create a new Interests of that user.")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:CreateUserInterest), "Create User Interest params", required: true)
    end

    response(200, "Ok", Schema.ref(:CreateUserInterest))
  end
  @doc """
  Update or create user interest list.
  """
  def save_user_interests(conn, params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    Enum.each(params["interest_list"], fn interest_id ->
      if interest_id["is_member"] == true do
        params = %{
          interest_id: String.trim(interest_id["interest_id"]),
          user_id: user_id,
          is_active: true
        }
        with nil <- Context.get_by(UserInterest,
        [interest_id: String.trim(interest_id["interest_id"]), user_id: user_id]),
        {:ok, data} <-  Context.create(UserInterest, params)
        do
          update_members_count(interest_id, true)
        else
          %{} = user_interest -> Context.update(UserInterest, user_interest, params)
        end

      else
        case Context.get_by(UserInterest,
               [interest_id: String.trim(interest_id["interest_id"]), user_id: user_id]) do
          nil -> nil
          %{} = data ->
            Context.delete(data)
            update_members_count(interest_id, false)
        end
      end
    end)
    render(conn, "user_interests_list.json", %{interest_list: params})
  end

  def update_members_count(interest_id, status) do
    case Context.get_by(UserInterestMeta, [interest_id: String.trim(interest_id["interest_id"])]) do
      %UserInterestMeta{} = data ->
        if status == true do
        Context.update(UserInterestMeta, data, %{total_members: data.total_members + 1})
        else
        Context.update(UserInterestMeta, data, %{total_members: data.total_members - 1})
        end
      nil -> nil
    end
  end

  #----------------------------------------------------------------------------
  # add_interest_users/2
  #----------------------------------------------------------------------------
  swagger_path :add_interest_users do
    post("/v1.0/add-interest-users")
    summary("Add users for an interest")
    description("Add single/multiple users of an interest by entering user_id according to your case.")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:AddInterestUsers), "Create Interest Users params", required: true)
    end

    response(200, "Ok", Schema.ref(:AddInterestUsersResponse))
  end
  @doc """
  Bulk add interest to list of users.
  """
  def add_interest_users(conn, %{"interest_id" => _interest_id, "user_ids" => _user_ids} = params) do
    case add_interest_users_sage(conn, params) do
      {:ok, _data} -> render(conn, "message.json", %{message: "Users Added successfully."})
      {:error, _, msg, _} -> render(conn, "interest.json", %{error: msg})
    end
  end

  #----------------------------------------------------------------------------
  # get_interest_users/2
  #----------------------------------------------------------------------------
  swagger_path :get_interest_users do
    get("/v1.0/get-interest-users")
    summary("Get Users by Interest ID")
    description("Get data by Interest ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      interest_id(:query, :string, "Interest ID", required: true)
      page(:query, :integer, "Page no.", required: true)
    end

    response(200, "Ok", Schema.ref(:UserInterests))
  end
  @doc """
  Get users with interest
  """
  def get_interest_users(conn, %{"interest_id" => interest_id, "page" => page}) do
    %{id: user_id, latitude: lat, longitude: long} = Api.Guardian.Plug.current_resource(conn)
    interest_users = Users.get_interest_users_sort_by_location_and_friends(
      %{interest_id: interest_id, user_id: user_id, lat: lat, long: long, page: page})
    render(conn, "user_interests.json", interest_users: interest_users)
  end

  #----------------------------------------------------------------------------
  # get_interest_topics/2
  #----------------------------------------------------------------------------
  swagger_path :get_interest_topics do
    get("/v1.0/get-interest-topics")
    summary("Get Interests Topics by Interest ID")
    description("Get data by Interest ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      interest_id(:query, :string, "Interest ID", required: true)
      page(:query, :integer, "Page no.", required: true)
    end

    response(200, "Ok", Schema.ref(:InterestTopics))
  end
  @doc """
  Get topics related to interest.
  """
  def get_interest_topics(conn, %{"interest_id" => interest_id, "page" => page}) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    interest_topics = InterestTopics.get_interest_topics_by_interest_id(user_id, interest_id, page)
    render(conn, "interest_topics.json", %{interest_topics: interest_topics, current_user_id: user_id})
  end

  #----------------------------------------------------------------------------
  # interests_feed/2
  #----------------------------------------------------------------------------
  swagger_path :interests_feed do
    get("/v1.0/interests-feed")
    summary("interests_feed-for-user")
    description("It will Create a interests for feed.")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      page(:query, :integer, "Page no.", required: true)
    end

    response(200, "Ok", Schema.ref(:Interest))
  end
  @doc """
    Get interests for user
  """
  def interests_feed(conn, %{"page" => page})  do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    case UserInterests.get_paginated_user_interests_list_by_user_id(user_id, page) do
      user_interests -> render(conn, "interests.json", %{interests: user_interests})
    end
  end

  #----------------------------------------------------------------------------
  # interests_feed_guest/2
  #----------------------------------------------------------------------------
  swagger_path :interests_feed_guest do
    get("/v1.0/guest/interests-feed")
    summary("interests_feed-for-guest")
    description("It will Create a interests for feed.")
    produces("application/json")

    parameters do
      device_id(:query, :string, "Device id", required: false)
      page(:query, :integer, "Page no.", required: true)
    end

    response(200, "Ok", Schema.ref(:Interest))
  end
  @doc """
  get interests for guest by device identifier.
  """
  def interests_feed_guest(conn, %{"device_id" => device_id, "page" => page})  do
    case UserInterests.get_paginated_user_interests_list_by_device_id(device_id, page) do
      user_interests -> render(conn, "interests.json", %{interests: user_interests})
    end
  end
  def interests_feed_guest(conn, _)  do
    render(conn, "interest.json", %{error: ["Interest does not exist"]})
  end

  #============================================================================
  # Internal Methods
  #============================================================================

  #----------------------------------------------------------------------------
  # create_sage/2
  #----------------------------------------------------------------------------
#  @doc """
#  Query helper methods should be managed by repos/domain objects.
#  """
  defp create_sage(_conn, params) do
    new()
    |> put(:params, params)
    |> run(:interest, &create_interest/2)
    |> run(:user_interest, &create_user_interest/2)
    |> run(:interest_meta, &create_user_interest_meta/2)
    |> Repo.transaction()
  end

  #----------------------------------------------------------------------------
  # create_interest/2
  #----------------------------------------------------------------------------
#  @doc """
#  Query helper methods should be managed by repos/domain objects.
#  """
  defp create_interest(_param, %{params: params}) do
    params = case AssetStore.upload_if_image_with_thumbnail(params, "image_name", "interests") do
      nil -> params
      {image_name, small_image_name} ->
        Map.merge(params, %{"image_name" => image_name, "small_image_name" => small_image_name})
    end
    case Context.create(Interest, params) do
      {:ok, interest} ->
        case make_shareable_link(interest) do
          {:ok, interest} ->
            {:ok, interest}
          _ -> {:error, "Error while making shareable link"}
        end
      {:error, error} -> {:error, error}
    end
  end

   #----------------------------------------------------------------------------
  # create_user_interest/2
  #----------------------------------------------------------------------------
#  @doc """
#  Query helper methods should be managed by repos/domain objects.
#  """

  def create_user_interest(_param, %{interest: interest}) do
    params = %{
      interest_id: interest.id,
      user_id: interest.created_by_id,
      is_active: true,
      status: :accepted,
      is_admin: true
    }
    case Context.create(UserInterest, params) do
      {:ok, user_interest} -> {:ok, user_interest}
      {:error, error} -> {:error, error}
    end
  end

  #----------------------------------------------------------------------------
  # create_user_interest_meta/2
  #----------------------------------------------------------------------------
#  @doc """
#  Query helper methods should be managed by repos/domain objects.
#  """
  defp create_user_interest_meta(_param, %{interest: interest}) do
    case Context.create(UserInterestMeta, %{total_members: 1,
      last_member_joined_at: DateTime.utc_now(),
      last_message_at: DateTime.utc_now(),
      interest_id: interest.id
    }) do
      {:ok, user_interest_meta} -> {:ok, user_interest_meta}
      {:error, error} -> {:error, error}
    end
  end

  #----------------------------------------------------------------------------
  # add_interest_users_sage/2
  #----------------------------------------------------------------------------
#  @doc """
#  Query helper methods should be managed by repos/domain objects.
#  """
  defp add_interest_users_sage(conn, params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    params = Map.put(params, "current_user_id", user_id)
    new()
    |> put(:params, params)
    |> run(:interest_users, &create_interest_users/2)
    |> run(:user_interest_meta, &update_user_interest_meta/2)
    |> Repo.transaction()
  end

  #----------------------------------------------------------------------------
  # create_interest_users
  #----------------------------------------------------------------------------
#  @doc """
#  Query helper methods should be managed by repos/domain objects.
#  """
  defp  create_interest_users(_ , %{params: %{"current_user_id" => current_user_id} = params}) do
    blocked_user_ids = UserBlocks.get_blocked_user_ids(current_user_id)
    result = Enum.reduce(params["user_ids"], [], fn user_id, acc ->
      with %{is_deleted: is_deleted, is_deactivated: is_deactivated, is_self_deactivated: is_self_deactivated} <- Context.get(User, user_id),
           false <- is_deleted or is_deactivated or is_self_deactivated or user_id in blocked_user_ids,
           true <- UserInterests.user_interest_exists_by_user_id(params["interest_id"], user_id) == false do
            param = %{
            interest_id: params["interest_id"],
            user_id: user_id,
            is_active: true}
           case Context.create(UserInterest, param) do
            {:ok, data} -> [data | acc]
            {:error, _error} -> acc
          end
        else
          _ -> acc
      end
    end)
    if result == [] do
      {:error, "No user interests created"}
      else
      {:ok, result}
    end
  end

  defp make_shareable_link(interest) do
      sl = Common.generate_url("private_interest_group", interest.id)
      interest
      |> Interest.changeset(%{shareable_link: sl})
      |> Repo.insert_or_update
  end

  #----------------------------------------------------------------------------
  # update_user_interest_meta
  #----------------------------------------------------------------------------
#  @doc """
#  Query helper methods should be managed by repos/domain objects.
#  """
  defp update_user_interest_meta(_, params) do
    case Interests.get_user_interest_meta(params.params["interest_id"])do
      nil ->
        case Context.create(UserInterestMeta, %{total_members: 1,
          last_member_joined_at: DateTime.utc_now(),
          last_message_at: DateTime.utc_now(),
          interest_id: params.params["interest_id"]}) do
          {:ok, user_interest_meta} -> {:ok, user_interest_meta}
          {:error, error} -> {:error, error}
        end
      data ->
        count = data.total_members + Enum.count(params.interest_users)
        Context.update(UserInterestMeta, data, %{total_members: count, last_member_joined_at: DateTime.utc_now()})
    end
  end

  #========================================================================
  # Swagger Definition
  #========================================================================
#  @doc """
#  Swagger MetaData.
#  """
  def swagger_definitions do
    %{
      AcceptInterest:
        swagger_schema do
          title("Accept Interest")
          description("Accept Interest")

          properties do
            id(:string, "Interest ID")
            status(:string, "Status")
          end

          example(%{
            id: "Interest ID",
            status: "Accepted, Rejected"
          })
        end,
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
      ListInterest:
        swagger_schema do
          title("List Of Interest")
          description("List Of Interest")

          example([
            %{
              id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
              interest_name: "Interest",
              description: "Test Interest",
              background_colour: "#f79432",
              status: 0,
              image_name: "interest-618c4478-631f-42e7-b2c6-4f258d0b080b.jpg",
              is_private: true,
              small_image_name: "interest-618c4478-631f-42e7-b2c6-4f258d0b080b.jpg",
              baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
              is_group_private: true
            },
            %{
              id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
              interest_name: "Interest",
              description: "Test Interest",
              background_colour: "#f79432",
              status: 0,
              image_name: "interest-618c4478-631f-42e7-b2c6-4f258d0b080b.jpg",
              baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
              is_private: true,
              small_image_name: "interest-618c4478-631f-42e7-b2c6-4f258d0b080b.jpg",
              is_group_private: true
            }
          ])
        end,
      CreateInterest:
        swagger_schema do
          title("Create Interest")
          description("Create Interest")

          properties do
            interest_name(:string, "Interest")
            description(:string, "Test Interest")
            background_colour(:string, "#f79432")
            image_name(:string, "")
            is_private(:boolean, true)
          end

          example(%{
            interest_name: "Interest",
            description: "Test Interest",
            background_colour: "#f79432",
            image_name: "",
            is_private: true
          })
        end,
      InterestInvite:
        swagger_schema do
          title("Update Interest")
          description("Update Interest")

          properties do
            status(:string, "Request Status")
            message(:string, "Message")
          end

          example(%{
            status: "Request Status",
            message: "Message"
          })
       end,
      UpdateInterest:
        swagger_schema do
          title("Update Interest")
          description("Update Interest")

          properties do
            interest_name(:string, "Interest")
            description(:string, "Test Interest")
            background_colour(:string, "#f79432")
            status(:boolean, true)
            image_name(:string, "test image")
            is_private(:boolean, true)
            is_group_private(:boolean, true)
          end

          example(%{
            interest_name: "Interest",
            description: "Test Interest",
            background_colour: "#f79432",
            status: true,
            image_name: "",
            baseUrl: "",
            is_private: true,
            is_group_private: true
          })
        end,
      ListUserInterest:
        swagger_schema do
          title("List Of User Interest IDs")
          description("List Of User Interest IDs")

          example(%{
            responseData: ["2cfd8787-315b-4f3b-8c50-83f2a14d3f3c",
              "41fe4093-5be0-434f-9db6-82ceb9f91948"]
          })
        end,
      CreateUserInterest:
        swagger_schema do
          title("Create User Interests")
          description("Create User Interests")

          properties do
            interest_list(:array, "interest ids")
          end

          example(%{
            interest_list:
              [%{interest_id: "2cfd8787-315b-4f3b-8c50-83f2a14d3f3c", is_member: true},
              %{interest_id: "41fe4093-5be0-434f-9db6-82ceb9f91948", is_member: false}]
          })
        end,
      AddInterestUsers:
        swagger_schema do
          title("Add Interest Users")
          description("Add single/multiple users of an interest")

          properties do
            interest_id(:string, "Interest")
            user_ids(:array, "Lists of Users Contacts")
          end

          example(%{
            interest_id: "b2b86ce2-6823-44ef-ac86-c633533bdddc",
            user_ids: [
              "a711bf85-963f-42ed-9728-c2047d5694fb",
              "1b32a4e2-67bc-11ec-90d6-0242ac120003",
              "33f65d6a-67bd-11ec-90d6-0242ac120003"
            ]
          })
        end,
      AddInterestUsersResponse:
        swagger_schema do
          title("Add Interest Users")
          description("Add single/multiple users of an interest")

          example(%{
            ResponseData: %{message: "Users Added Sucessfully.", success: true}
          })
        end,

      UserInterests:
        swagger_schema do
          title("User Interest by Room ID")
          description("User Interest By Room ID")

          example(%{
            responseData: %{
              data: [
                %{
                  userImage: "user/3ea14269-bc6f-4bdc-a1f4-99f70135cb8c.jpg",
                  userId: "3d5c7bb8-453b-4b89-ab5d-0d60dac63b34",
                  lastName: "name",
                  firstName: "test",
                  email: "superadmin2@jetzy.com",
                  aseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                },
                %{
                  userImage: "user/3ea14269-bc6f-4bdc-a1f4-99f70135cb8c.jpg",
                  email: "superadmin@jetzy.com",
                  firstName: "Super",
#                  userImage: "",
                  lastName: "Admin",
                  userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                  aseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                }
              ],
              pagination: %{
                page: 1,
                totalPages: 1,
                totalRows: 2
              }
            }
          })
        end,
      InterestTopics:
        swagger_schema do
          title("User Interest by Room ID")
          description("User Interest By Room ID")

          example(%{
            responseData: %{
              data: [
                %{
                  updatedAt: "2022-01-17T07:38:03Z",
                  topicName: "Interest Topic11",
                  roomId: "ae902a4c-aef7-405e-8f3a-6ccd47b98c6e",
                  interestId: "2cfd8787-315b-4f3b-8c50-83f2a14d3f3c",
                  insertedAt: "2022-01-17T07:38:03Z",
                  imageName: "",
                  id: "74e43387-18a6-4d94-b03a-3557bfabd9ba",
                  description: "Interest Topic Description",
                  deletedAt: "",
                  createdById: "a711bf85-963f-42ed-9728-c2047d5694fb",
                  createdBy: "",
                  baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                },
                %{
                  updatedAt: "2022-01-17T07:37:55Z",
                  topicName: "Interest Topic9",
                  roomId: "f23e8ac5-5cda-401e-af18-200a18b63ced",
                  interestId: "2cfd8787-315b-4f3b-8c50-83f2a14d3f3c",
                  insertedAt: "2022-01-17T07:37:55Z",
                  imageName: "",
                  id: "77a92152-1f7f-4d1d-9b8a-bcf08dd373da",
                  description: "Interest Topic Description",
                  deletedAt: "",
                  createdById: "a711bf85-963f-42ed-9728-c2047d5694fb",
                  createdBy: "",
                  baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                }
              ],
              pagination: %{
                page: 1,
                totalPages: 1,
                totalRows: 2
              }
            }
          })
        end,
      InviteUserInterest:
        swagger_schema do
          title("Invite User to Private Interests")
          description("Invite User to Private Interests")

          properties do
            interest_id(:stringt, "interest id", required: true)
            users(:array, "user ids", required: true)
            status(:string, "Status", required: true)
          end

          example(%{
            interest_id: "2cfd8787-315b-4f3b-8c50-83f2a14d3f3c",
            users: ["2cfd8787-315b-4f3b-8c50-83f2a14d3f3c", "41fe4093-5be0-434f-9db6-82ceb9f91948"],
            status: "request"
          })
        end,

      InterestEvents:
        swagger_schema do
          title("User Interest by Room ID")
          description("User Interest By Room ID")

          example(%{
            responseData: %{
              data: [
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
                },
                %{
                  longitude: 74.3141829,
                  latitude: 31.5656822,
                  interestId: "2cfd8787-315b-4f3b-8c50-83f2a14d3f3c",
                  image: "user_event/1f0e1481-1f99-4971-bd22-dc59821ea692.jpg",
                  id: "d94ecbb5-3a1b-42e4-996f-db9bd0817a41",
                  formatedAddress: "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
                  eventStartTime: "16:15:47",
                  eventStartDate: "2022-01-07",
                  eventEndTime: "22:15:47",
                  eventEndDate: "2022-01-10",
                  description: "This is a first description test",
                  baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                }
              ],
              pagination: %{
                page: 1,
                totalPages: 1,
                totalRows: 2
              }
            }
          })
        end
    }
  end
end
