defmodule Data do

  alias Data.Helper.MigratorHelperChangeset

  @moduledoc """
  Documentation for Data.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Data.hello()
      :world

  """
  def hello do
    :world
  end

  
  def starter() do
    IO.puts("Welcome. Please write code here related to Users and UserRoles and other tables")
    IO.puts("Handle Users")
  end

  def run1() do

    tables = [
      %{table: "Admin", order_by: "AdminId"},
      %{table: "CommentSources", order_by: "CommentSourceId"},
      %{table: "Status", order_by: "Id"},
      %{table: "UserPostType", order_by: "PostTypeId"},
      %{table: "LikeSources", order_by: "LikeSourceId"},
      %{table: "NotificationTypes", order_by: "Id"},
      %{table: "ShoutoutType", order_by: "ShoutoutTypeId"},
      %{table: "CityLatLongs", order_by: "LatLongId"},
      %{table: "Restaurants", order_by: "RestaurantId"},

      %{table: "DropDownMasterTable", order_by: "MasterId"},
      %{table: "DropDownSubMasterTable", order_by: "SubMasterId"},
      %{table: "NotificationSettings", order_by: "Id"},
#      %{table: "Interest", order_by: "Id"}, # We are doing it with csv # We are doing it with csv
      %{table: "admin_test", order_by: "AdminId"},
      %{table: "Career", order_by: "Id"},
      %{table: "RewardTier", order_by: "RewardTierId"},
      %{table: "RewardManager", order_by: "RewardManagerId"},
      %{table: "Splash", order_by: "SplashId"},
      %{table: "RewardOffer", order_by: "RewardOfferId"},
      %{table: "RewardImages", order_by: "ImageId"},
      %{table: "UserEmergencyContact", order_by: "UserEmergencyContactId"},
      %{table: "UserImages", order_by: "UserImageId"},
      %{table: "AddressComponents", order_by: "AddressComponentId"},
      %{table: "UserPointBalance", order_by: "BalanceId"},
      %{table: "EventEmails", order_by: "Id"},
      %{table: "HadCDNUsers", order_by: "UserId"},
      %{table: "HadCdnMoments", order_by: "MomentId"},
      %{table: "RewardImages", order_by: "ImageId"},
      %{table: "MailContentSetting", order_by: "MessageId"},
    ]
    Enum.map(tables, fn
      %{table: table, order_by: order_by} -> MigratorHelperChangeset.get_data_starter(table, order_by)
    end)
  end
  def run4() do

    tables = [
      %{table: "UserShoutouts", order_by: "ShoutoutId"},
      %{table: "AddressMomentMapping", order_by: "AddressMomentMappingId"},
      %{table: "AddressShoutoutMapping", order_by: "ShoutoutMappingId"},
      %{table: "UserShoutoutsTagged", order_by: "TaggedId"},

      %{table: "TestMoments", order_by: "MomentId"},
      %{table: "UserMoments", order_by: "MomentId"},
      %{table: "UserMomentLike", order_by: "MomentLikeId"},
      %{table: "UserMomentsImages", order_by: "UserMomentsImageId"},

      %{table: "UserShoutoutImage", order_by: "UserShoutoutImageId"},
      %{table: "Comments", order_by: "CommentId"},
      %{table: "UserCommentTagged", order_by: "TaggedId"},

      %{table: "UserShoutoutsImages", order_by: "Id"}, #this is table
      %{table: "UserShoutoutInterest", order_by: "ShoutoutInterestId"},
      %{table: "UserShoutoutsPrivate", order_by: "Id"},
      %{table: "ReportMessages", order_by: "ReportMessageId"},
      %{table: "CommentReplies", order_by: "CommentReplyId"},
      %{table: "NotificationsRecord", order_by: "Id"},
      %{table: "LikeDetails", order_by: "CommentLikeId"},
    ]
    Enum.map(tables, fn
      %{table: table, order_by: order_by} -> MigratorHelperChangeset.get_data_starter(table, order_by)
    end)
  end
  def run2() do
    tables = [
      %{table: "UserSession", order_by: "SessionId"},
      %{table: "UserCountry", order_by: "UserCountryId"},
      %{table: "UserPushToken", order_by: "UserPushTokenId"},
      %{table: "UserProfileImage", order_by: "ProfileImageId"},
      %{table: "UserChatSession", order_by: "ChatSessionId"},
      %{table: "UserOfferTransaction", order_by: "UserOfferId"},
      %{table: "UserReport", order_by: "ReportId"},
      %{table: "UserRewardTransaction", order_by: "UserRewardId"},
      %{table: "RegisterUserWithPrivateInterest", order_by: "Id"},
      %{table: "UserFriends", order_by: "UserFriendId"},
      %{table: "UserPreference", order_by: "PreferenceId"},
      %{table: "UserInterest", order_by: "UserInterestId"},
      %{table: "UserLastActivityLog", order_by: "UserLastActivityLogId"},
      %{table: "UserReference", order_by: "UserRefId"},
      %{table: "PushNotificationLog", order_by: "NotificationLogId"},
    ]
    Enum.map(tables, fn
      %{table: table, order_by: order_by} -> MigratorHelperChangeset.get_data_starter(table, order_by)
    end)
  end
  def run3() do
    tables = [
      %{table: "ELMAH_Error", order_by: "ErrorId"},
      %{table: "UserGeoLocation", order_by: "GeoLocationId"},
      %{table: "UserGeoLocationLog", order_by: "GeoLocationLogId"},
      %{table: "APIUserActivityLog", order_by: "ActivityLogId"},
    ]
    Enum.map(tables, fn
      %{table: table, order_by: order_by} -> MigratorHelperChangeset.get_data_starter(table, order_by)
    end)
  end
end
