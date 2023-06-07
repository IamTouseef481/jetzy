#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.ReleaseController do
  @moduledoc """
  Mobile App/Backend Release Details and Upgrade Checks.
  """
  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false
  use ApiWeb, :controller
  use PhoenixSwagger
  require Logger

  
  alias Data.Context
  alias Data.Context.{Users, UserReferrals, UserImages, UserShoutouts, UserInstalls, UserFollows, GuestInterests, UserReferralCodeLogs}
  alias Data.Schema.{User, UserReferral, UserImage, OTPToken, UserBlock, UserInstall, UserSetting, DeletedUser,
                     UserInterest, UserGeoLocation, ReportMessage, UserFollow, UserGeoLocation, UserGeoLocationLog, UserRewardTransaction, UserReferralCodeLog}
  alias Api.Guardian
  alias Api.Workers.{
    WelcomeEmailWorker,
    PushNotificationSignupWorker}
  alias ApiWeb.Utils.Common
  alias Data.Repo

  #============================================================================
  # Controller Actions
  #============================================================================
  
  #----------------------------------------------------------------------------
  # user_verification_request/2
  #----------------------------------------------------------------------------
  swagger_path :upgrade_check do
    get("/v1.0/client/{type}/version/{version}/upgrade-check")
    summary("Upgrade Check")
    description("""
    /api/v1.0/client/ios/version/798/upgrade-check?os=iOS+13.1&user=0000-00-00-0000&locale=en-CA&lat=12.32&lng=42.0

    Return packet indicating if upgrade is available, notes and required/not-required flag.
    
    [Testing]
    Use 0.0.0 or 0 in version field for a required  upgrade.
    Use 0.0.1 or 1 in version field for a recommended upgrade.
    Use 0.0.2 or 2 in version field for a optional upgrade.
    current stub will return {available: false} for any other version strings.
    """)
    produces("application/json")
    parameters do
      type(:path, :string, "ios,android,web,admin,backend", required: true)
      version(:path, :string, "Release Build Number e.g. 798", required: true)
      os(:query, :string, "iOS/Android/PC Operating System. as reported by device/browser.", required: true)
      user(:query, :string, "User GUID if known: for soft roll outs/progressive roll outs.", required: false)
      locale(:query, :string, "Mobile/OS reported Language Locale e.g. en-US", required: false)
      lng(:query, :float, "longitude if known - for geo roll-out.", required: false)
      lat(:query, :float, "latitude if known - for geo roll-out", required: false)
    end
    response(200, "Ok", Schema.ref(:UpgradeCheckResponse))
  end
  @doc """
  Check if device-type has required/recommended upgrade.
  """
  def upgrade_check(conn, %{"type" => type, "version" => version} = params) do
    cond do
      version in ["0.0.0","0"] ->
        conn
        |> json(%{available: true, type: :required, version: "1.2.3", note: "Hard Coded Note Explaining Hard Upgrade Requirement"})
      version in ["0.0.1","1"] ->
        conn
        |> json(%{available: true, type: :recommended, version: "1.2.3", note: "Hard Coded Note Explaining Soft Upgrade Requirement"})
      version in ["0.0.2","2"] ->
        conn
        |> json(%{available: true, type: :optional, version: "1.2.3", note: "Hard Coded Note Explaining Trivial Upgrade Requirement"})
      :else ->
        conn
        |> json(%{available: false, type: :none, version: nil, note: nil})
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
      UpgradeCheckResponse:
        swagger_schema do
          title("Upgrade Check Response")
          description("Response object with details about upgrade availability and requirement level (type). localized note may be displayed to user to explain why they should or must upgrade.")
          properties do
            available(:boolean, "Is an update of some type available?")
            type(:string, "none,optional,recommended,required")
            version(:string, "String encoded available release version or null. Most likely of Major.Minor.Bug or integer as string format ")
            note(:string, "Message that can be displayed advising user why the must, should, or might wish to upgrade.")
          end
          example(%{
            available: true,
            type: "required",
            version: "5.2.1",
            note: "It's (insert year) upgrade already for pete's sake.",
          })
        end,
    }
  end
end
