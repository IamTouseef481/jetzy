#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_1.UserController do
  @moduledoc """
  User sign-in, request reactivation, sign-out, search nearby, etc. api calls.
  """
  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false
  use ApiWeb, :controller
  use Filterable.Phoenix.Controller
  use PhoenixSwagger
  require Logger
  import Bcrypt, only: [hash_pwd_salt: 1]
  import Api.Helper.Utils, only: [number: 0]
  
  @referral_code_url Application.get_env(:api, :configuration)[:referral_code_url]
  @profile_create_reward "6eb58c08-5a90-4847-9059-f3392cdb550e"
  
  alias Data.Context
  alias Data.Context.{Users, UserReferrals, UserImages, UserShoutouts, UserInstalls, UserFollows, GuestInterests}
  alias Data.Schema.{User, UserReferral, UserImage, OTPToken, UserBlock, UserInstall, UserSetting,
                     UserInterest, UserGeoLocation, ReportMessage, UserFollow, UserGeoLocation, UserGeoLocationLog, UserRewardTransaction}
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
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post("/v1.1/sign-up")
    summary("User Signup")
    description("Signup the User with the params in the body. if you set is_referral=false, then you dont need any referral code. (dev/stage only) ")
    produces("application/json")
    parameters do
      body(:body, Schema.ref(:SignUp), "Signup the User with the params in the body. if you set is_referral=false (dev/stage only), then you dont need any referral code", required: true)
    end
    response(200, "Ok", Schema.ref(:User))
  end
  
  @doc """
  sign_up with or without referral code
  """
  def create(conn, params) do
    context = Noizu.ElixirCore.CallingContext.system()
    if Users.email_already_exist?(params) == true do
      case Context.get_by(User, [email: params["email"]]) do
        %User{is_deactivated: true} ->
          conn
          |> put_status(409)
          |> json(%{success: false, message: "Your account is deactivated. But you can reactivate it"})
        user = %User{is_deleted: true} ->
          with {:ok, _} <- Users.clear_deleted_user(user, context) do
            create(conn, params)
          else
            _ ->
              conn
              |> put_status(409)
              |> json(%{success: false, message: "Internal System Error, Unable to register for this email address"})
          end
        _ ->
          conn
          |> put_status(409)
          |> json(%{success: false, message: "This email is already registered"})
      end
    else
      with {:ok, %User{} = user} <- Users.create_user_from_request(params, context),
           {:ok, token, _claims} <- Guardian.encode_and_sign(user),
           {:ok, _} <- User.create_user_installs(user, Map.merge(params["installs"], %{"current_jwt" => token})) do
        
        # Record user creation
        Jetzy.Module.Telemetry.Analytics.user_registration(conn, user)
        
        conn
        |> render("jwt.json", jwt: token, user: user)
      else
        {:ok, %{user: user, message: message}} ->
          conn |> put_status(200) |> render("user.json", user: user, message: message)
  
        {:error, %Ecto.Changeset{} = changeset} ->
          # This should not be sent, generic message should be delivered
          # response code should be set.
          render(conn, "error.json", %{error: Common.decode_changeset_errors(changeset)})
  
        {:error, details} ->
          # This should not be sent, message should be sent based on details value
          conn
          |> put_status(422)
          |> json(%{
            success: false,
            errors: details
          })
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
      CreateUser:
        swagger_schema do
          title("User SignUp")
          description("User SignUp")
          
          properties do
            email(:string, "Email")
            social_id(:string, "Social ID")
            created_date(:date, "Created Date")
            quick_blox_id(:string, "Quick Blox ID")
            approval_status(:string, "Approval Status")
            image_name(:string, "Image Name")
            current_city(:string, "Current City")
            first_name(:string, "First Name")
            last_name(:string, "Last Name")
            gender(:string, "Gender")
            login_type(:string, "Login Type")
            home_town_city(:string, "Home Town City")
            longitude(:float, "Long")
            school(:string, "School")
            password(:string, "Password")
            current_country(:string, "Current Country")
            dob(:date, "Date Of Birth")
            is_referral(:boolean, "Is Referred")
            dob_full(:string, "Full Date OF Birth")
            is_active(:boolean, "Is Account Active or not")
            is_email_verified(:boolean, "Email Verified")
            is_deactivated(:boolean, "Is Deactivated")
            referral_code(:string, "Referral Code")
            latitude(:float, "Lat")
            panic_message(:string, "Panic Message")
            user_about(:string, "User About")
            home_town_country(:string, "Home Town Country")
            quick_blox_password(:string, "Quick Blox Password")
            friend_code(:string, "Friend Code")
            current_jwt(:string, "Current JWT")
          end
          
          example(%{
            deleted_at: "2021-09-06T00:00:00",
            is_deleted: "false",
            email: "superadmin@jetzy.com",
            social_id: "",
            created_date: "2021-09-06",
            quick_blox_id: "",
            approval_status: "",
            image_name: "",
            current_city: "USA",
            last_name: "Admin",
            gender: "",
            login_type: "",
            last_modified_date: "2021-09-06",
            first_name: "Super",
            home_town_city: "Nevada",
            longitude: "92.98385212321",
            school: "String.t | nil",
            password: "123",
            current_country: "",
            dob: "",
            is_referral: "",
            dob_full: "String.t | nil",
            is_active: true,
            is_email_verified: true,
            referral_code: "",
            is_deactivated: "",
            latitude: "",
            panic_message: "",
            user_about: "",
            home_town_country: "",
            quick_blox_password: "",
            friend_code: "",
            current_jwt: ""
          })
        end,
    }
  end
end
