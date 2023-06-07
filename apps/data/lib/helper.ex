defmodule Data.Helper do
  alias Data.Context
  alias Data.Context.{UserRewardTransactions, RewardManagers}
  alias Data.Schema.{UserRewardTransaction, Permission, Resource, RewardManager}
  require Logger
  def firebase_api_key() do
    Application.get_env(:data, :firebase)[:api_key] || Application.get_env(:api, :firebase)[:api_key]
  end

  def update_points(user_id, activity_type) do
    case RewardManagers.get_reward_offer_by_activity_type(activity_type) do
      nil -> :do_nothing
      %RewardManager{id: reward_id, winning_point: points, activity: remarks} ->
        previous_points = case Data.Context.Users.point_balance(user_id) do
                            %{points: points} -> trunc(points)
                            _ -> 0
                          end
        new_balance_point = previous_points + points
        Context.create(UserRewardTransaction, %{
          user_id: user_id,
          reward_id: reward_id,
          point: points,
          balance_point: new_balance_point,
          remarks: remarks,
          is_completed: true
        })
    end
  end
  
  def generate_url(event, id, title \\ "", description \\ "", image \\ "https://jetzyapp.com/Splash/images/logo2.png") do
    link = "https://jetzyapp.com?event=#{event}&id=#{id}"
    headers = []
    options = [ssl: [{:versions, [:'tlsv1.2', :'tlsv1.1', :tlsv1]}], recv_timeout: 45_000]
    api_key = firebase_api_key()
    dynamic_link = %{
      "dynamicLinkInfo": %{
        "domainUriPrefix": "https://jetzy.page.link",
        "link": link,
        "analyticsInfo": %{
          "googlePlayAnalytics": %{"utmCampaign": event, "utmMedium": "", "utmSource": id},
          "itunesConnectAnalytics": %{"at": id,"ct": event, "mt": "","pt": ""}
        },
        "androidInfo": %{"androidFallbackLink": "",
          "androidLink": "",
          #          "androidMinPackageVersionCode": "4.1",
          "androidPackageName": "com.icreon.travelconnect"
        },
        "iosInfo": %{
          "iosAppStoreId": "1019546379",
          "iosBundleId": "Jetzy",
          "iosCustomScheme": "",
          "iosFallbackLink": "",
          "iosIpadBundleId": "",
          "iosIpadFallbackLink": ""
        },
        "navigationInfo": %{
          "enableForcedRedirect": true,
        },
        "socialMetaTagInfo": %{
          "socialTitle": title,
          "socialDescription": description,
          "socialImageLink": image
        }
      },
      "suffix": %{
        "option": "SHORT"
      }
    }
    body = Poison.encode!(dynamic_link)
    HTTPoison.start()
    case HTTPoison.post("https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=#{api_key}", body, headers, options) do
      {:ok, response} ->
        body = Poison.decode!(response.body)
        Map.get(body, "shortLink")
      {:error, cause} ->
        Logger.error("#{inspect cause, label: "failed with cause"}")
    end
  end
  
end