#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.RewardOfferController do
  @moduledoc """
  Manage rewards, user points and reward redemptions.
  @todo management and user specific calls should be placed in different controller actions to avoid security mistakes.
  """


  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use PhoenixSwagger
  alias Data.Context
  alias Data.Repo
  alias ApiWeb.Utils.Common
  use Filterable.Phoenix.Controller
  import Ecto.Query, warn: false
  alias Data.Context.{UserRewardTransactions, RewardOffers}
  alias Data.Schema.{RewardOffer, UserRewardTransaction, RewardManager}

  
  
  #============================================================================
  # filterable
  #============================================================================
  filterable do
    #----------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------
    #    paginateable(per_page: 20)
        @options default: ""
        filter base_query(query, _value, _conn) do
          status_active = "f991ccc4-84d9-11ec-9f8f-a45e60e7f2b3"
          query
          |> where([ro], ro.is_deleted == false)
          |> where([ro], ro.status_id == ^status_active)
        end

    #----------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------
    @options param: [:user_latitude, :user_longitude]
    filter filter_by_location(
             query,
             %{user_latitude: user_latitude, user_longitude: user_longitude},
             _conn
           ) do
      {latitude, _} = Float.parse(user_latitude)
      {longitude, _} = Float.parse(user_longitude)

      query
      |> order_by(
           [u],
           fragment(
             "ST_DistanceSphere(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326))",
             u.latitude,
             u.longitude,
             ^latitude,
             ^longitude
           )
         )
    end

    #----------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------
    filter offer_name(query, value, _conn) do
      query
      |> where([u], ilike(u.offer_name, ^"#{value}"))
    end

    #----------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------
    filter offer_description(query, value, _conn) do
      query
      |> where([u], ilike(u.offer_description, ^"#{value}"))
    end

    #----------------------------------------------------------------------------
    #
    #----------------------------------------------------------------------------
    filter location(query, value, _conn) do
      query
      |> where([u], ilike(u.location, ^"#{value}"))
    end

  end


  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get("/v1.0/reward-offers")
    summary("List Reward Offers")
    description("List Reward Offers")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      page(:query, :integer, "Page", required: true)
      user_longitude(:query, :float, "User Longitude")
      user_latitude(:query, :float, "User Latitude")
      location(:query, :string, "Location")
      offer_name(:query, :string, "Offer Name")
      offer_description(:query, :string, "Offer Description")
    end

    response(200, "Ok", Schema.ref(:ListRewardOffers))
  end

  @doc """
  Get list of reward offers for active user.
  """
  def index(conn, %{"page" => page}) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    with {:ok, query, _filter_values} <- apply_filters(RewardOffer, conn),
         query = RewardOffers.paginate_sorted_on_is_pinned(query, page),
         entries = Context.preload_selective(query.entries, [[:tier, :status, :reward_images]]) do
      render(conn, "rewards_offers.json", %{rewards_offers: Map.merge(query, %{entries: entries, current_user_id: current_user_id})})
    end
  end

  #----------------------------------------------------------------------------
  # redeemed_reward_history/2
  #----------------------------------------------------------------------------
  swagger_path :redeemed_reward_history do
    get("/v1.0/redeemed-reward-history")
    summary("List of redeemed reward history")
    description("List of redeemed reward history")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      page(:query, :integer, "Page", required: true)
      user_id(:query, :string, "User Id")
      end

    response(200, "Ok", Schema.ref(:ListRedeemedRewardHistory))
  end

  @doc """
  Get list of redeemed reward history.
  """
  def redeemed_reward_history(conn, %{"page" => page} = params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    user_id = if params["user_id"] do
      params["user_id"]
      else
      user_id
    end
    
    #    case UserRewardTransactions.get_history_for_redeemed_reward(user_id, page) do
    #      data -> render(conn, "redeemed_reward_history_list.json", %{history_list: data})
    #    end
    case UserRewardTransactions.get_point_transactions(user_id, page) do
      data -> render(conn, "point_txn_history.json", %{transactions: data})
    end
  end

  #----------------------------------------------------------------------------
  # total_points/2
  #----------------------------------------------------------------------------
  swagger_path :total_points do
    get("/v1.0/total-reward-points")
    summary("Get Total Reward Points of User")
    description("Get Total Reward Points of User")
    produces("application/json")
    security([%{Bearer: []}])

    response(200, "Ok", Schema.ref(:TotalRewardPoints))
  end

  @doc """
  Get reward points for active user.
  """
  def total_points(conn, _) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    points = Data.Context.Users.point_balance(user_id)
    render(conn, "point_balance.json", points)
  end

  #----------------------------------------------------------------------------
  # redeem_reward/2
  #----------------------------------------------------------------------------
  swagger_path :redeem_reward do
    get("/v1.0/redeem-reward/{id}")
    summary("Redeem Reward Offer By ID")
    description("Redeem Reward Offer By ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Reward Offer ID", required: true)
    end

    response(200, "Ok", Schema.ref(:RedeemRewardOffer))
  end

  @doc """
  Redeem active user's reward.
  """
  def redeem_reward(conn, %{"id" => id}) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    with %RewardOffer{} = reward_offer <- Context.get(RewardOffer, id) || {:error, "Record not found"},
         %{points: points} <- Data.Context.Users.point_balance(user_id),
         true <- is_integer(points && trunc(points)) || {:error, "Insufficient Points for redemption"},
         true <- points > reward_offer.point || {:error, "Insufficient Points for redemption"},
         {:ok, _} <- Context.create(Data.Schema.UserOfferTransaction, %{user_id: user_id,
           offer_id: reward_offer.id, point: reward_offer.point,
           balance_point: trunc(points) - reward_offer.point # TODO stop calculating balance like this. use roll up table.
         }) do
      render(conn, "reward_transaction.json",
        %{message: "Point has been redeemed", status: "1"})
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        Jetzy.Module.Telemetry.Errors.query_failure(:point_redemption_failure, user_id, changeset, conn, %{user: user_id, offer: id})
        render(conn, "reward_transaction.json", %{message: "An internal error occurred! We're investigating it. Please try again later.", status: "0"})
      {:error, message} -> render(conn, "reward_transaction.json", %{message: message, status: "0"})
      _ ->
        # @TODO Telemetry
        render(conn, "reward_transaction.json", %{message: "Something went wrong", status: "0"})
    end
  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get("/v1.0/reward-offers/{id}")
    summary("Get Reward Offer By ID")
    description("Get Reward Offer By ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Reward Offer ID", required: true)
    end

    response(200, "Ok", Schema.ref(:RewardOffer))
  end

  @doc """
  Get specific reward by id for active user.
  """
  def show(conn, %{"id" => id}) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    case Context.get(RewardOffer, id) do
      nil -> render(conn, "reward_offer.json", %{error: ["Reward offer does not exist"]})
      %{} = reward_offer -> reward_offer = Context.preload_selective(reward_offer, [:tier, :status, :reward_images])
                            render(conn, "reward_offer.json", %{reward_offer: Map.merge(reward_offer, %{current_user_id: current_user_id})})
    end
  end

  #----------------------------------------------------------------------------
  # add_jetpoints/2
  #----------------------------------------------------------------------------
  swagger_path :add_jetpoints do
    post("/v1.0/add-jetpoints")
    summary("Add Jetpoints to User")
    description("Add Jetpoints to User")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:AddJetPoints), "Add jetpoints params", required: true)
    end
    response(200, "Ok", Schema.ref(:JetPoint))
  end

  @doc """
  Add Jetzy Points to user.
  @todo how is this authenticated to prevent disfavored users from granting themselves points?
  """
  def add_jetpoints(conn, %{"points" => points, "reward_id" => reward_id} = params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    ApiWeb.Utils.Common.update_points(user_id, reward_id,points, params["remarks"])
    render(conn, "reward_offer.json", %{message: "Jetpoints added successfully!"})
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
#  swagger_path :create do
#    post("/v1.0/reward-offers")
#    summary("Create new Reward Offer")
#    description("Create new Reward Offer")
#    produces("application/json")
#    security([%{Bearer: []}])
#
#    parameters do
#      body(:body, Schema.ref(:CreateRewardOffer), "Params for Creating New Reward Offer", required: true)
#    end
#
#    response(200, "Ok", Schema.ref(:RewardOffer))
#  end
#
#  @doc """
#  Create new reward entry.
#  """
#  def create(conn, %{"offer_name" => _offer_name, "offer_description" => _offer_description,
#    "tier_id" => _tier_id, "status_id" => _status_id} = params) do
#    case Context.create(RewardOffer, params) do
#      {:ok, reward_offer} ->
#        make_shareable_link(reward_offer)
#        conn
#        |> put_status(200)
#        |> json(%{
#          ResponseData: %{
#            success: true,
#            message: params
#          }
#        })
#      {:error, _error} ->
#        conn
#        |> put_status(400)
#        |> json(%{
#          ResponseData: %{
#            success: false,
#            message: "Something went wrong"
#          }
#        })
#    end
#  end
#  def create(conn, _) do
#    conn
#    |> put_status(400)
#    |> json(%{
#      ResponseData: %{
#        success: false,
#        message: "No clause matching"
#      }
#    })
#  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
#  swagger_path :update do
#    put("/v1.0/reward-offers/{id}")
#    summary("Update Reward Offer by ID")
#    description("Update Reward Offer by ID")
#    produces("application/json")
#    security([%{Bearer: []}])
#
#    parameters do
#      id(:path, :string, "Reward Offer ID", required: true)
#      body(:body, Schema.ref(:UpdateRewardOffer), "Params for Updating Reward Offer", required: true)
#    end
#
#    response(200, "Ok", Schema.ref(:RewardOffer))
#  end
#
#  @doc """
#  Update reward entry.
#  """
#  def update(conn, %{"id" => reward_offer_id} = params) do
#    with %RewardOffer{} = reward_offer <- Context.get(RewardOffer, reward_offer_id),
#         {:ok, _updated_data} <- Context.update(RewardOffer, reward_offer, params) do
#      conn
#      |> put_status(200)
#      |> json(%{
#        ResponseData: %{
#          success: true,
#          message: params
#        }
#      })
#    else
#      {:error, _} ->
#        conn
#        |> put_status(400)
#        |> json(%{
#          ResponseData: %{
#            success: false,
#            message: "Something went wrong"
#          }
#        })
#    end
#  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
#  swagger_path :delete do
#    PhoenixSwagger.Path.delete("/v1.0/reward-offers/{id}")
#    summary("Delete Reward Offer")
#    description("Delete Reward Offer")
#    produces("application/json")
#    security([%{Bearer: []}])
#
#    parameters do
#      id(:path, :string, "Reward Offer ID", required: true)
#    end
#
#    response(200, "Ok", Schema.ref(:RewardOffer))
#
#  end
#  @doc """
#  Delete interest.
#  """
#  def delete(conn, %{"id" => id} = _params) do
#    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
#    with %RewardOffer{} = reward_offer <- Context.get(RewardOffer, id),
#         {:ok, %RewardOffer{} = reward_offer} <- Context.delete(reward_offer) do
#      render(conn, "reward_offer.json", %{message: "Reward Deleted Successfully"})
#    else
#      nil -> render(conn, "reward_offer.json", %{error: ["Reward not found"]})
#      {:error, error} -> render(conn, "reward_offer.json", %{error: error})
#    end
#  end

#  def make_shareable_link(reward) do
#    Task.start(fn ->
#      sl = Common.generate_url("reward", reward.id)
#      reward
#      |> RewardOffer.changeset(%{shareable_link: sl})
#      |> Repo.insert_or_update
#    end)
#  end
  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      ListRewardOffers:
        swagger_schema do
          title("List Reward Offers")
          description("List Reward Offers")

          example(%{
            responseData: %{
              pagination: %{
                total_pages: 2,
                page: 1,
                total_rows: 10
              },
              data: [
                %{
                  imagePath:
                    "af17c444-3d56-4e66-bee3-00d498768efe--635726938977967397--37a95302-6724-49c4-ae58-772debd86376",
                  offerDescription: "This is new test",
                  offerName: "Luxury Test",
                  pointRequired: 150_000,
                  rewardOfferId: "af17c444-3d56-4e66-bee3-00d498768efe",
                  latitude: 40.721546,
                  longitude: -74.00145987,
                  is_pinned: true,
                  event_start_date: "2022-05-02",
                  event_end_date: "2022-05-06",
                  multi_redeem_allowed: true,
                  is_redeemed: false,
                  price_of_ticket: 1000,
                  link: "http://jetzy.com",
                  location: "254, Broadway, New York, NY 10007, USA",
                  tier: %{
                    tier_name: "Tier 1",
                    description: "Brown"
                  },
                  status: %{
                    status_id: "23453782-ff3f-43f9-823d-6789afcfb3a0",
                    status: "Active"
                  }
                },
                %{
                  imagePath:
                    "a11519fb-69bd-4503-a1f2-029f43692044--637287148448444851--6f677db8-2a53-40fb-aeb8-efdc857eac8f",
                  offerDescription:
                    "Offer Description",
                  offerName: "June 25th - 6pm EST Yin Yoga Class with Hana Sykorova",
                  pointRequired: 1,
                  rewardOfferId: "b11519fb-69bd-4503-a1f2-029f43692046",
                  latitude: 40.721546,
                  longitude: -74.00145987,
                  is_pinned: false,
                  event_start_date: "2022-05-02",
                  event_end_date: "2022-05-06",
                  multi_redeem_allowed: false,
                  is_redeemed: false,
                  price_of_ticket: 2000,
                  link: "http://jetzy.com",
                  location: "254, Broadway, New York, NY 10007, USA",
                  tier: %{
                    tier_name: "Tier 1",
                    description: "Brown"
                  },
                  status: %{
                    status_id: "23453782-ff3f-43f9-823d-6789afcfb3a0",
                    status: "Active"
                  }
                }
              ]
            }
          })
        end,
      RewardOffer:
        swagger_schema do
          title("Reward Offer Details")
          description("Reward Offer Details")

          example(%{
            ResponseData: %{
              imagePath:
                "a11519fb-69bd-4503-a1f2-029f43692044--637287148448444851--6f677db8-2a53-40fb-aeb8-efdc857eac8f",
              offerDescription:
                "Offer Description",
              offerName: "June 25th - 6pm EST Yin Yoga Class with Hana Sykorova",
              pointRequired: 1,
              rewardOfferId: "a11519fb-69bd-4503-a1f2-029f43692044",
              latitude: 40.721546,
              longitude: -74.00145987,
              is_pinned: false,
              event_start_date: "2022-05-02",
              event_end_date: "2022-05-06",
              multi_redeem_allowed: false,
              is_redeemed: false,
              price_of_ticket: 2000,
              link: "http://jetzy.com",
              location: "254, Broadway, New York, NY 10007, USA",
              tier_id: "af17c445-4c56-4e66-bee3-00d496768efg",
              status: %{
                status_id: "23453782-ff3f-43f9-823d-6789afcfb3a0",
                status: "Active"
              }
            }
          })
        end,
      CreateRewardOffer:
        swagger_schema do
          title("Create Reward Offer")
          description("Create a Reward Offer")

          properties do
            imageName(:string, "Name of image")
            offerDescription(:string, "Create Reward Offer Details")
            offerName(:string, "offerName")
            pointRequired(:integer, "pointRequired")
            latitude(:integer, "latitude")
            longitude(:integer, "longitude")
            is_pinned(:boolean, "is_pinned")
            event_start_date(:string, "event_start_date")
            event_end_date(:string, "event_end_date")
            multi_redeem_allowed(:boolean, "multi_redeem_allowed")
            price_of_ticket(:integer, "price_of_ticket")
            link(:string, "link")
            location(:string, "location")
            tier_id(:string, "tier_id")
            status_id(:string, "status_id")
          end
          example(%{
            imageName:
              "a11519fb-69bd-4503-a1f2-029f43692044--637287148448444851--6f677db8-2a53-40fb-aeb8-efdc857eac8f",
            offerDescription:
              "<p class=\"p1\" style=\"margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-stretch: normal; line-height: normal; font-family: &quot;Helvetica Neue&quot;; color: rgb(0, 0, 0);\">\n Join Hana for a FREE live online 60-minute yin yog",
            offerName: "June 25th - 6pm EST Yin Yoga Class with Hana Sykorova",
            pointRequired: 1,
            latitude: 40.721546,
            longitude: -74.00145987,
            is_pinned: false,
            event_start_date: "2022-05-02",
            event_end_date: "2022-05-06",
            multi_redeem_allowed: false,
            price_of_ticket: 2000,
            link: "http://jetzy.com",
            location: "254, Broadway, New York, NY 10007, USA",
            tier_id: "af17c445-4c56-4e66-bee3-00d496768efg",
            status_id: "af17c445-4c56-4e66-bee3-00d496768efg"

          })
        end,
      UpdateRewardOffer:
        swagger_schema do
          title("Update Reward Offer")
          description("Update a Reward Offer")

          properties do
            imageName(:string, "Name of image")
            offerDescription(:string, "Create Reward Offer Details")
            offerName(:string, "offerName")
            pointRequired(:integer, "pointRequired")
            latitude(:integer, "latitude")
            longitude(:integer, "longitude")
            is_pinned(:boolean, "is_pinned")
            event_start_date(:string, "event_start_date")
            event_end_date(:string, "event_end_date")
            multi_redeem_allowed(:boolean, "multi_redeem_allowed")
            price_of_ticket(:integer, "price_of_ticket")
            link(:string, "link")
            location(:string, "location")
          end
          example(%{
            imageName:
              "a11519fb-69bd-4503-a1f2-029f43692044--637287148448444851--6f677db8-2a53-40fb-aeb8-efdc857eac8f",
            offerDescription:
              "<p class=\"p1\" style=\"margin: 0px; font-variant-numeric: normal; font-variant-east-asian: normal; font-stretch: normal; line-height: normal; font-family: &quot;Helvetica Neue&quot;; color: rgb(0, 0, 0);\">\n Join Hana for a FREE live online 60-minute yin yog",
            offerName: "June 25th - 6pm EST Yin Yoga Class with Hana Sykorova",
            pointRequired: 1,
            latitude: 40.721546,
            longitude: -74.00145987,
            is_pinned: false,
            event_start_date: "2022-05-02",
            event_end_date: "2022-05-06",
            multi_redeem_allowed: false,
            price_of_ticket: 2000,
            link: "http://jetzy.com",
            location: "254, Broadway, New York, NY 10007, USA",

          })
        end,
      TotalRewardPoints:
        swagger_schema do
          title("Total Reward Points of User")
          description("Total Reward Points of User")

          example(%{
            ResponseData: %{
              totalPoint: 163.0
            }
          })
        end,
      RedeemRewardOffer:
        swagger_schema do
          title("Redeem Reward Offer")
          description("Redeem Reward Offer")

          example(%{
            ResponseData: %{
              message: "Point has been redeemed",
              status: "1"
            }
          })
        end,
      JetPoint:
        swagger_schema do
          title("Add Jetpoints")
          description("Add Jetpoints")

          example(%{
            ResponseData: %{
              message: "Jetpoints added successfully!",
              success: true
            }
          })
        end,
      ListRedeemedRewardHistory:
        swagger_schema do
          title("List Redeemed Reward History")
          description("List Redeemed Reward History")

          example(%{
            ResponseData: %{
              pagination: %{
                totalRows: 19,
                totalPages: 2,
                page: 1
              },
              data: [
                %{
                  remarks: "Sign in",
                  points: 1,
                  insertedAt: "2022-03-25T06:26:50Z",
                  id: "4a3d2d11-2966-4e1e-b764-9e2f28f6350a"
                },
                %{
                  remarks: "User's referral code is used",
                  points: 100,
                  insertedAt: "2022-03-25T06:28:00Z",
                  id: "773ccde7-f2cf-4461-a0a6-da140268dd4f"
                }
              ]
            }
          })
        end,
      AddJetPoints:
        swagger_schema do
          title("Add Jetpoints")
          description("Add Jetpoints")

          properties do
            points(:integer, "Points to add")
            remarks(:string, "Add remarks/comments (optional)")
            reward_id(:string, "7871c88c-e87e-489b-8f2a-41f2820ea871")
          end

          example(%{
            points: 5,
            remarks: "",
            reward_id: "7871c88c-e87e-489b-8f2a-41f2820ea871"
          })
        end

    }
  end
end
