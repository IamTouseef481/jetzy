#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.AdminRewardController do
  @moduledoc """
  API for managing Rewards.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Context
  use Filterable.Phoenix.Controller
  alias Data.Context.{RewardManagers}
  alias Data.Schema.{RewardManager}
  alias Data.Context
  alias ApiWeb.Api.Admin.V1_0.AdminRewardView, as: View

#============================================================================
# Controller Actions
#============================================================================

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get("/v1.0/admin/admin-rewards")
    summary("List Rewards")
    description("List Rewards")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      page(:query, :integer, "Page", required: true)
      page_size(:query, :integer, "Page Size")
    end

    response(200, "Ok", Schema.ref(:ListRewards))
  end

  @doc """
  Get list of rewards.
  """
  def index(conn, %{"page" => page} = params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    page_size = params["page_size"] || 20
    rewards = RewardManagers.paginate_rewards(page, page_size)
      conn
      |> put_view(View)
      |> render("rewards.json", %{rewards: rewards})
  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get("/v1.0/admin/admin-rewards/{id}")
    summary("Get Reward by id")
    description("Get Reward by id")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Reward ID", required: true)
    end

    response(200, "Ok", Schema.ref(:Reward))

  end
  @doc """
  Show reward
  """
  def show(conn, %{"id" => id} = _params) do
    with %RewardManager{} = reward <- Context.get(RewardManager, id) do
      conn
      |> put_view(View)
      |> render("reward.json", %{reward: reward})
    else
      nil ->
        conn
        |> put_view(View)
        |> render("reward.json", %{error: "No reward found"})
    end

  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put("/v1.0/admin/admin-rewards/{id}")
    summary("Update Reward by id")
    description("Update Reward by id")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Reward ID", required: true)
      body(:body, Schema.ref(:UpdateReward), "SignIn Params", required: true)
    end

    response(200, "Ok", Schema.ref(:Reward))

  end
  @doc """
  Update reward
  """
  def update(conn, %{"id" => id} = params) do
    with %RewardManager{} = reward <- Context.get(RewardManager, id),
      false <- Map.has_key?(params, "activity_type"),
         {:ok, %RewardManager{} = reward} <- Context.update(RewardManager, reward, params) do
      conn
      |> put_view(View)
      |> render("reward.json", %{reward: reward})
    else
      nil ->
        conn
        |> put_view(View)
        |> render("reward.json", %{error: "No reward found"})
      true ->
        conn
        |> put_view(View)
        |> render("reward.json", %{error: "Can not update activity type"})
        {:error, error} ->
          conn
          |> put_view(View)
          |> render("reward.json", %{error: error})
    end

  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete("/v1.0/admin/admin-rewards/{id}")
    summary("Delete Reward by id")
    description("Delete Reward by id")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Reward ID", required: true)
    end

    response(200, "Ok", Schema.ref(:Reward))

  end
  @doc """
  Delete reward
  """
  def delete(conn, %{"id" => id} = _params) do
    with %RewardManager{} = reward <- Context.get(RewardManager, id),
    {:ok, %RewardManager{}} <- Context.update(RewardManager, reward, %{is_deleted: true, deleted_at: DateTime.utc_now}) do
      conn
      |> put_view(View)
      |> render("reward.json", %{reward: reward})
    else
      nil ->
        conn
        |> put_view(View)
        |> render("reward.json", %{error: "No reward found"})
      {:error, error} ->
        conn
        |> put_view(View)
        |> render("reward.json", %{error: error})
    end

  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post("/v1.0/admin/admin-rewards")
    summary("Create new reward")
    description("Create new reward")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:UpdateReward), "Reward Params", required: true)
    end

    response(200, "Ok", Schema.ref(:Reward))

  end
  @doc """
  Create reward
  """
  def create(conn, params) do
    mappings = Ecto.Enum.mappings(RewardManager, :activity_type)
    activity_type = mappings[RewardManagers.get_max_activivty_type()] + 1
    params = Map.put(params, "activity_type", activity_type)
    with {:ok, %RewardManager{} = reward} <- Context.create(RewardManager, params) do
      conn
      |> put_view(View)
      |> render("reward.json", %{reward: reward})
    else
      {:error, error} ->
        conn
        |> put_view(View)
        |> render("reward.json", %{error: error})
    end

  end








#========================================================================
# Swagger Definition
#========================================================================

  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
  %{
  ListRewards: swagger_schema do
    title("List Rewards")
    description("List Rewards")
    example(
      %{
        ResponseData: %{
        pagination: %{
        totalRows: 40,
        totalPages: 2,
        pageSize: 20,
        page: 1
      },
        data: [%{
        id: "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b34",
        winning_point: 100,
        activity: "Sign in",
        activity_type: 8
        },
      %{
        id: "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b34",
        winning_point: 100,
        activity: "Sign in",
        activity_type: 8
      }
    ]
  }})
    end,
      Reward: swagger_schema do
        title("Reward")
        description("Reward")
        example(
          %{
          id: "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b34",
          winning_point: 100,
          activity: "Sign in",
          activity_type: 8
        })
      end,
    UpdateReward: swagger_schema do
      title("Update Reward")
      description("Update Reward")
      properties do
        winning_point(:integer, "Winning Poin")
        activity(:string, "Activity")
      end
      example(
        %{
          winning_point: 100,
          activity: "Sign Up",

        })
    end
    }
  end
end