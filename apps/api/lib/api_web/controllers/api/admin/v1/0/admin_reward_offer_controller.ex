#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.AdminRewardOfferController do
  @moduledoc """
  API for managing Admin Reward offers.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false
  use ApiWeb, :controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Repo
  alias ApiWeb.Utils.Common
  use Filterable.Phoenix.Controller
  import Ecto.Query, warn: false
  alias Data.Context.{UserRewardTransactions, RewardOffers}
  alias Data.Schema.{RewardOffer, UserRewardTransaction, RewardManager, RewardImage, RewardTier}
  alias ApiWeb.Api.V1_0.RewardOfferView
  alias JetzyModule.AssetStoreModule
  alias Data.Context

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get("/v1.0/admin/admin-reward-offers")
    summary("List Reward Offers")
    description("List Reward Offers")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      page(:query, :integer, "Page", required: true)
      page_size(:query, :integer, "Page Size")
    end

    response(200, "Ok", Schema.ref(:ListRewardOffers))
  end

  @doc """
  Get list of reward offers for active user.
  """
  def index(conn, %{"page" => page} = params) do
    %{id: current_user_id} = Api.Guardian.Plug.current_resource(conn)
    page_size = params["page_size"] || 20
    with query = RewardOffers.paginate_reward_offers_list(page, page_size),
         entries = Context.preload_selective(query.entries, [[:tier, :status, :reward_images]]) do
    conn
    |> put_status(200)
    |> put_view(RewardOfferView)
    |> render("rewards_offers.json", %{rewards_offers: Map.merge(query, %{entries: entries, current_user_id: current_user_id})})
    end
  end


  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post("/v1.0/admin/admin-reward-offers")
    summary("Create new Reward Offer")
    description("Create new Reward Offer")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:CreateRewardOffer), "Params for Creating New Reward Offer", required: true)
    end

    response(200, "Ok", Schema.ref(:RewardOffer))
  end

  @doc """
  Create new reward entry.
  """
  def create(conn, %{"offer_name" => _offer_name, "offer_description" => _offer_description,
    "tier_id" => _tier_id, "status_id" => _status_id} = params) do
     uploaded_images = case params["image_name"] do
       nil -> []
       [] -> []
      images ->
        uploaded_images = AssetStoreModule.upload_if_image_with_thumbnail(params, "image_name", "reward_offer")
    end
    params = Map.put(params, "image_name", List.first(uploaded_images) |> elem(0)) |> Map.put("small_image_name", List.first(uploaded_images) |> elem(1))
    case Context.create(RewardOffer, params) do
      {:ok, reward_offer} ->
        Task.start(fn  ->
          save_images(uploaded_images, reward_offer.id)
        end)
        make_shareable_link(reward_offer)
        conn
        |> put_status(200)
        |> json(%{
          ResponseData: %{
            success: true,
            message: params
          }
        })
      {:error, _error} ->
        conn
        |> put_status(400)
        |> json(%{
          ResponseData: %{
            success: false,
            message: "Something went wrong"
          }
        })
    end
  end
  def create(conn, _) do
    conn
    |> put_status(400)
    |> json(%{
      ResponseData: %{
        success: false,
        message: "No clause matching"
      }
    })
  end


  def make_shareable_link(reward) do
    Task.start(fn ->
      sl = Common.generate_url("reward", reward.id)
      reward
      |> RewardOffer.changeset(%{shareable_link: sl})
      |> Repo.insert_or_update
    end)
  end



  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    put("/v1.0/admin/admin-reward-offers/{id}")
    summary("Update Reward Offer by ID")
    description("Update Reward Offer by ID")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Reward Offer ID", required: true)
      body(:body, Schema.ref(:UpdateRewardOffer), "Params for Updating Reward Offer", required: true)
    end

    response(200, "Ok", Schema.ref(:RewardOffer))
  end

  @doc """
  Update reward entry.
  """

  def update(conn, %{"id" => reward_offer_id, "image_name" => images, "delete_images" => delete_images} = params) do
        with %RewardOffer{} = reward_offer <- Context.get(RewardOffer, reward_offer_id),
        uploaded_images <- AssetStoreModule.upload_if_image_with_thumbnail(params, "image_name", "reward_offer"),
          _ <- save_images(uploaded_images, reward_offer.id),
          _ <- delete_images(delete_images, reward_offer.id),
          params <- update_params(params, reward_offer, delete_images, uploaded_images),
        {:ok, %RewardOffer{}} <- Context.update(RewardOffer, reward_offer, params) do
      conn
      |> put_status(200)
      |> json(%{
        ResponseData: %{
          success: true,
          message: params
        }
      })
    else
      {:error, _} ->
        conn
        |> put_status(400)
        |> json(%{
          ResponseData: %{
            success: false,
            message: "Something went wrong"
          }
        })
        nil ->
        conn
        |> put_status(400)
        |> json(%{
          ResponseData: %{
            success: false,
            message: "Reward not found"
          }
        })
    end
  end

  def update(conn, %{"id" => reward_offer_id, "image_name" => images} = params) do
        with %RewardOffer{} = reward_offer <- Context.get(RewardOffer, reward_offer_id),
             uploaded_images <- AssetStoreModule.upload_if_image_with_thumbnail(params, "image_name", "reward_offer"),
              _ <- save_images(uploaded_images, reward_offer.id),
             params <- Map.delete(params, "image_name"),
             {:ok, _updated_data} <- Context.update(RewardOffer, reward_offer, params) do
          uploaded_images = Enum.map(uploaded_images, fn {img, _} -> img end)
          params = Map.put(params, "image_name", uploaded_images)
          conn
          |> put_status(200)
          |> json(%{
            ResponseData: %{
              success: true,
              message: params
            }
          })
        else
          {:error, _} ->
            conn
            |> put_status(400)
            |> json(%{
              ResponseData: %{
                success: false,
                message: "Something went wrong"
              }
            })
         nil ->
           conn
           |> put_status(400)
           |> json(%{
             ResponseData: %{
               success: false,
               message: "Reward not found"
             }
           })
        end
  end

  def update(conn, %{"id" => reward_offer_id, "delete_images" => delete_images} = params) do
        with %RewardOffer{} = reward_offer <- Context.get(RewardOffer, reward_offer_id),
              _ <- delete_images(delete_images, reward_offer.id),
              params <- update_params(params, reward_offer, delete_images, []),
             {:ok, _updated_data} <- Context.update(RewardOffer, reward_offer, params) do
          conn
          |> put_status(200)
          |> json(%{
            ResponseData: %{
              success: true,
              message: params
            }
          })
        else
          {:error, _} ->
            conn
            |> put_status(400)
            |> json(%{
              ResponseData: %{
                success: false,
                message: "Something went wrong"
              }
            })
          nil ->
            conn
            |> put_status(400)
            |> json(%{
              ResponseData: %{
                success: false,
                message: "Reward not found"
              }
            })
        end
  end

  def update(conn, %{"id" => reward_offer_id} = params) do
    with %RewardOffer{} = reward_offer <- Context.get(RewardOffer, reward_offer_id),
         {:ok, _updated_data} <- Context.update(RewardOffer, reward_offer, params) do
      conn
      |> put_status(200)
      |> json(%{
        ResponseData: %{
          success: true,
          message: params
        }
      })
    else
      {:error, _} ->
        conn
        |> put_status(400)
        |> json(%{
          ResponseData: %{
            success: false,
            message: "Something went wrong"
          }
        })
      nil ->
        conn
        |> put_status(400)
        |> json(%{
          ResponseData: %{
            success: false,
            message: "Reward not found"
          }
        })
    end
  end

  #----------------------------------------------------------------------------
  # delete/2
  #----------------------------------------------------------------------------
  swagger_path :delete do
    PhoenixSwagger.Path.delete("/v1.0/admin/admin-reward-offers/{id}")
    summary("Delete Reward Offer")
    description("Delete Reward Offer")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Reward Offer ID", required: true)
    end

    response(200, "Ok", Schema.ref(:RewardOffer))

  end
  @doc """
  Delete interest.
  """
  def delete(conn, %{"id" => id} = _params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    with %RewardOffer{} = reward_offer <- Context.get(RewardOffer, id),
         {:ok, %RewardOffer{} = reward_offer} <- Context.delete(reward_offer) do
      conn
      |> put_view(RewardOfferView)
      |> render("reward_offer.json", %{message: "Reward Deleted Successfully"})
    else
      nil ->
        put_view(conn, RewardOfferView)
        |> render("reward_offer.json", %{error: ["Reward not found"]})
      {:error, error} ->
        put_view(conn, RewardOfferView)
        |> render("reward_offer.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # show/2
  #----------------------------------------------------------------------------
  swagger_path :show do
    get("/v1.0/admin/admin-reward-offers/{id}")
    summary("Get Reward Offer by id")
    description("Get Reward Offer by id")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      id(:path, :string, "Reward Offer ID", required: true)
    end

    response(200, "Ok", Schema.ref(:RewardOffer))

  end
  @doc """
  Show reward
  """
  def show(conn, %{"id" => id} = _params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    with %RewardOffer{} = reward_offer <- Context.get(RewardOffer, id) do
      reward_offer = Context.preload_selective(reward_offer, [[:tier, :status, :reward_images]]) |> Map.put(:current_user_id, user_id)
      conn
      |> put_view(RewardOfferView)
      |> render("reward_offer.json", %{reward_offer: reward_offer})
    else
      nil ->
        put_view(conn, RewardOfferView)
        |> render("reward_offer.json", %{error: ["Reward not found"]})
      {:error, error} ->
        put_view(conn, RewardOfferView)
        |> render("reward_offer.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # list_tiers/2
  #----------------------------------------------------------------------------
  swagger_path :list_reward_tiers do
    get "/v1.0/admin/list-reward-tiers"
    summary "Tiers Details"
    description "Tiers Details"
    produces "application/json"
    security [%{Bearer: []}]
    response 200, "Ok", Schema.ref(:ListOfTiers)
  end
  @doc """
  Fetch list of reward tiers.
  """
  def list_reward_tiers(conn, _params) do
    conn
    |> put_view(RewardOfferView)
    |> render("tiers.json", tiers: Context.list(RewardTier))
  end

  defp save_images(images, reward_id) do
    Enum.each(images, fn {img, thumb} = image ->
      Context.create(RewardImage, %{image_name: img, small_image_name: thumb, reward_offer_id: reward_id})
    end)
  end

  defp delete_images(images, reward_offer_id) do
    Enum.each(images, fn image_name ->
      case Context.get_by(RewardImage, [image_name: image_name, reward_offer_id: reward_offer_id]) do
        nil -> :ok
        image -> Context.delete(image)
      end
    end)
  end

  defp update_params(params, reward_offer, delete_images, uploaded_images) do
    if reward_offer.image_name not in delete_images do
      Map.delete(params, "image_name")
    else
      cond do
        uploaded_images == [] ->
          case Data.Context.RewardImages.get_images_by_reward_offer_id(reward_offer.id) do
            [] -> Map.merge(params, %{"image_name" => nil, "small_image_name" => nil})
            reward_images ->
              image = List.first(reward_images)
              Map.merge(params, %{"image_name" => image.image_name, "small_image_name" => image.small_image_name})
          end

        true ->
          {image_name, small_image_name} = List.first(uploaded_images)
          Map.merge(params, %{"image_name" => image_name, "small_image_name" => small_image_name})
      end
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
            imageName(:map, "List of images")
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
            code(:string, "code")
          end
          example(%{
            imageName:
              ["a11519fb-69bd-4503-a1f2-029f43692044--637287148448444851--6f677db8-2a53-40fb-aeb8-efdc857eac8f","a11519fb-69bd-4503-a1f2-029f43692044--637287148448444851--6f677db8-2a53-40fb-aeb8-efdc857eac8f"],
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
            status_id: "af17c445-4c56-4e66-bee3-00d496768efg",
            code: "12212"
          })
        end,
      UpdateRewardOffer:
        swagger_schema do
          title("Update Reward Offer")
          description("Update a Reward Offer")

          properties do
            imageName(:map, "List of images to insert")
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
            delete_images(:map, "List of images to delete")
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
            delete_images: ["reward_offer/a41842b2-2b33-4604-9bd6-e55792aa9b94.jpg"]
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
        end,
      ListOfTiers: swagger_schema do
        title "List of Reward Tiers"
        description "List of Reward Tiers"
        example [
          %{
            id: "03bf0706-b7e9-33b8-aee5-c6142a816478",
            tierName: "Tier 1",
            description: "Bronze",
            startPoint: 100.0,
            endPoint: 1000.0
          },
          %{
            id: "03bf0706-b7e9-33b8-aee5-c6142a816478",
            tierName: "Tier 2",
            description: "Silver",
            startPoint: 100.0,
            endPoint: 1000.0
          }

        ]
      end

    }
  end
end
