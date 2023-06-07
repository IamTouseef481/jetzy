#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.InterestTopicController do
  @moduledoc """
  Manage Interest Topics.
  @todo need a definition of interest and of topic. - keith
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Context.{RoomUsers, RoomMessages, InterestTopics, InterestTopics}
  alias Data.Schema.{InterestTopic, Room, RoomUser, InterestTopic}
  alias JetzyModule.AssetStoreModule, as: AssetStore

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get("/v1.0/interest-topic-list/{interest_id}")
    summary("Get List OF Interest Topics")
    description("Get List OF Interest Topics")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      interest_id(:path, :string, "Interest ID", required: true)
    end
    response(200, "Ok", Schema.ref(:ListInterestTopic))
  end
  @doc """
  Get topic list for specified interest.
  """
  def index(conn, %{"interest_id" => interest_id} = _params) do
    %{id: user_id} = _current_user = Api.Guardian.Plug.current_resource(conn)
    interest_topics = InterestTopics.list_topics_by_interest(interest_id)
    #    interest_topics = Context.list(InterestTopic)
    render(conn, "interest_topics.json", %{interest_topics: interest_topics, current_user_id: user_id})
  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get("/v1.0/interest-topics/{id}")
    summary("Get Interest Topics By ID")
    description("Get Interest Topics By ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Interest Topic ID", required: true)
    end

    response(200, "Ok", Schema.ref(:InterestTopic))
  end
  @doc """
  Get interest topic.
  """
  def show(conn, %{"id" => id}) do
    %{id: user_id} = current_user = Api.Guardian.Plug.current_resource(conn)

    case Context.get(InterestTopic, id) do
      nil ->
        render(conn, "interest_topic.json", %{error: ["Interest topic does not exist"]})

      %{} = interest_topic ->
        if RoomUsers.user_exists_in_room(interest_topic.room_id, user_id) == false do
          Context.create(RoomUser, %{room_id: interest_topic.room_id, user_id: user_id})
        end
        interest_topic = Map.merge(interest_topic, %{created_by: current_user})
        render(conn, "show.json", %{
          interest_topic: interest_topic,
          current_user_id: user_id
        })
    end
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post("/v1.0/interest-topics")
    summary("Create Interest Topics")
    description("Create Interest Topics after changing the interest_id, topic_name and description according
    to your case.")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:CreateInterestTopic), "Create Interest Topic params", required: true)
    end

    response(200, "Ok", Schema.ref(:InterestTopic))
  end
  @doc """
  Create Interest Topic.
  """
  def create(conn, %{"image_name" => _image_name } = params) do
    %{id: user_id} = current_user = Api.Guardian.Plug.current_resource(conn)
    params = Map.put(params, "created_by_id", user_id)
    params = case AssetStore.upload_if_image_with_thumbnail(params, "image_name", "interests") do
      nil -> params
      {image_name, small_image_name} -> Map.merge(params, %{"image_name" => image_name, "small_image_name" => small_image_name})
    end
    case Context.create(InterestTopic, params) do
      {:ok, interest_topic} ->
        with {:ok, room} <- Context.create(Room, %{room_type: "interest_topic_chat"}),
             {:ok, _room_users} <- Context.create(RoomUser, %{room_id: room.id, user_id: user_id}),
             {:ok, %InterestTopic{} = interest_topic} <-
               Context.update(InterestTopic, interest_topic, %{room_id: room.id}) do
          ApiWeb.Api.V1_0.UserChatController.broadcast_to_chat_listing(user_id, room)
          interest_topic = Map.merge(interest_topic, %{created_by: current_user})
          render(conn, "show.json", %{
            interest_topic: interest_topic,
            room_messages: [],
            current_user_id: user_id
          })
        else
          {:error, error} ->
            Context.delete(interest_topic)
            render(conn, "interest_topic.json", %{error: error})
          nil -> render(conn, "interest_topic.json", %{error: "User Role Does not exist!"})

        end

      {:error, error} ->
        render(conn, "interest_topic.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put("/v1.0/interest-topics/{id}")
    summary("Update Interest Topic")
    description("Update Interest Topics after changing the interest_id, topic_name and description according
    to your case.")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Interest Topic ID", required: true)

      body(:body, Schema.ref(:UpdateInterestTopic), "Update Interest Topic Params", required: true)
    end

    response(200, "Ok", Schema.ref(:InterestTopic))
  end
  @doc """
  Update interest topic.
  """
  def update(conn, %{"id" => id} = params) do
    %{id: user_id} = current_user = Api.Guardian.Plug.current_resource(conn)
    with %InterestTopic{} = interest_topic <- Context.get(InterestTopic, id),
         true <- interest_topic.created_by_id == user_id,
         image <- AssetStore.upload_if_image_with_thumbnail(params, "image_name", "interest"),
         params <- (if is_tuple(image), do: Map.merge(params, %{"image_name" => elem(image, 0), "small_image_name" => elem(image, 1)}), else: params),
         {:ok, %InterestTopic{} = interest_topic} <-
           InterestTopics.update(interest_topic, params) do
      interest_topic = Map.merge(interest_topic, %{created_by: current_user})
      render(conn, "show.json", %{
        interest_topic: interest_topic,
        room_messages: RoomMessages.get_messages_by_room(interest_topic.room_id, 1, user_id),
        current_user_id: user_id
      })
    else
      false -> render(conn, "interest_topic.json", %{error: ["You are not permitted to perform this action"]})
      nil -> render(conn, "interest_topic.json", %{error: ["Interest topic not found"]})
      {:error, error} -> render(conn, "interest_topic.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete("/v1.0/interest-topics/{id}")
    summary("Delete InterestTopics")
    description("Delete Interest Topic")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Interest Topic ID", required: true)
    end

    response(200, "Ok", Schema.ref(:InterestTopic))
  end
  @doc """
  Delete interest topic.
  """
  def delete(conn, %{"id" => id} = _params) do
    %{id: user_id} = current_user = Api.Guardian.Plug.current_resource(conn)
    with %InterestTopic{} = interest_topic <- Context.get(InterestTopic, id),
         true <- interest_topic.created_by_id == user_id,
         {:ok, %InterestTopic{} = interest_topic} <- Context.delete(interest_topic) do
      interest_topic = Map.merge(interest_topic, %{created_by: current_user})
      render(conn, "show.json", %{
        interest_topic: interest_topic,
        room_messages: [],
        current_user_id: user_id
      })
    else
      false -> render(conn, "interest_topic.json", %{error: ["You are not permitted to perform this action"]})
      nil -> render(conn, "interest_topic.json", %{error: ["Interest topic not found"]})
      {:error, error} -> render(conn, "interest_topic.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # chat_group_members/2
  #----------------------------------------------------------------------------
  swagger_path :chat_group_members do
    get("/v1.0/chat-group-members")
    summary("Get All Members list by Room ID")
    description("Get All Members list by Room ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      room_id(:query, :string, "Room ID", required: true)
      page(:query, :integer, "Page no.", required: true)
    end

    response(200, "Ok", Schema.ref(:InterestTopicMember))
  end
  @doc """
  Get chat room members for given interest topic.
  @todo Does this belong in this controller? - keith
  """
  def chat_group_members(conn, %{"room_id" => room_id, "page" => page}) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)

    room_user_data = InterestTopics.get_all_members_list_interest_topic(%{room_id: room_id, user_id: user_id, page: page})
    render(conn, "chat_group_members.json", room_user: room_user_data)
  end

  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      InterestTopic:
        swagger_schema do
          title("Interest Topic")
          description("Interest Topic")

          example(%{
            ResponseData: %{
              interestTopic: %{
                id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
                topic_name: "Interest Topic",
                description: "Interest Topic Description",
                interest_id: "b640adbb-75a8-47a7-b3b6-77ef777d2a11",
                room_id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
                createdBy: %{
                  firstName: "test",
                  lastName: "name",
                  profileImage: "user-bc6038a1-4eb2-4bab-aaa5-eb5be8f3676b.jpg",
                  roleId: "user"
                },
                createdById: "8d045495-19ca-490e-b18d-8e881107e3bd",
                imageName: "user-a90c76d4-ba43-42d6-8c8f-975dda4c9a2b.jpg",
                baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
              }
            }
          })
        end,
      ListInterestTopic:
        swagger_schema do
          title("List Of Interest Topic")
          description("List Of Interest Topic")

          example(%{
            ResponseData: %{
              interestTopics: [
                %{
                  id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
                  topic_name: "Interest Topic",
                  description: "Interest Topic Description",
                  interest_id: "b640adbb-75a8-47a7-b3b6-77ef777d2a11",
                  room_id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11"
                },
                %{
                  id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11",
                  topic_name: "Interest Topic",
                  description: "Interest Topic Description",
                  interest_id: "b640adbb-75a8-47a7-b3b6-77ef777d2a11",
                  room_id: "b640adbb-75a8-47a7-b3b6-77ef718d2a11"
                }
              ]
            }
          })
        end,
      CreateInterestTopic:
        swagger_schema do
          title("Create Interest Topic")
          description("Create Interest Topic")

          properties do
            topic_name(:string, "Title")
            description(:string, "Description")
            interest_id(:string, "Interest ID")
            image_name(:string, "Base64 encode value")
          end

          example(%{
            topic_name: "Interest Topic",
            description: "Interest Topic Description",
            interest_id: "2cfd8787-315b-4f3b-8c50-83f2a14d3f3c",
            image_name: ""
          })
        end,
      UpdateInterestTopic:
        swagger_schema do
          title("Update Interest Topic")
          description("Update Interest Topic")

          properties do
            topic_name(:string, "Title")
            description(:string, "Description")
            image_name(:string, "Base64 value")
          end

          example(%{
            topic_name: "Interest Topic",
            description: "Interest Topic Description",
            image_name: ""
          })
        end,

      InterestTopicMember:
        swagger_schema do
          title("List of all members by Room ID")
          description("List of all members by Room ID")

          example(%{
            responseData: %{
              data: [
                %{
                  userImage: "user/1b55cdbd-5dea-4d6b-802e-70bf173ba311.jpg",
                  userId: "203a2d1e-dab1-4e03-acbd-7ce88db518e6",
                  roomId: "bb5ecba7-0515-468b-8f91-5711b4bc4d98",
                  lastName: "name",
                  firstName: "test",
                  baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                },
                %{
                  userImage: "null",
                  userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                  roomId: "bb5ecba7-0515-468b-8f91-5711b4bc4d98",
                  lastName: "Admin",
                  firstName: "Super",
                  baseUrl: "null"
                },
                %{
                  userImage: "user/55682946-8c67-495d-b976-544a151283e8.jpg",
                  userId: "b280cf1f-ce8e-4f53-8581-0086ffb0759d",
                  roomId: "bb5ecba7-0515-468b-8f91-5711b4bc4d98",
                  lastName: "name",
                  firstName: "test",
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
