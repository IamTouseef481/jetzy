#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.UserController do
  @moduledoc """
  User sign-in, request reactivation, signout, search nearby, etc. api calls.
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


  @sendgrid_website Application.get_env(:data, :sendgrid)[:website] || "https://jetzy.com"
  @sendgrid_cdn Application.get_env(:data, :sendgrid)[:cdn] || "https://jetzy.com"


  @referral_code_url Application.get_env(:api, :configuration)[:referral_code_url]
  @profile_create_reward "6eb58c08-5a90-4847-9059-f3392cdb550e"

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
  # filterable
  #============================================================================
  filterable do
    @options default: ""
    filter base_query(query, _, conn) do
      current_user = Guardian.Plug.current_resource(conn)
      query
      |> join(:left, [u], ugl in UserGeoLocation, on: u.id == ugl.user_id)
      |> join(:inner, [u], ui in UserInterest, on: ui.user_id == u.id)
      |> where([u], u.effective_status == :active)
      |> (fn query ->
            case current_user do
              nil -> query
              _ -> where(query, [u],
                  fragment("? not in (select user_to_id from user_blocks where user_from_id = ? and is_blocked = true)",
                    u.id, ^UUID.string_to_binary!(current_user.id)))
                |> where([u], u.id != ^current_user.id)
            end
          end).()
    end

    @options param: [:user_latitude, :user_longitude], cast: :float
    filter filter_by_location(query, %{user_latitude: latitude, user_longitude: longitude}, conn) do
      radius = conn.body_params["radius"]
      if !is_nil(latitude) && !is_nil(longitude) && !is_nil(radius) do
        distance_unit = conn.body_params["distance_unit"] || "miles"
        {distance, multiplication_factor} =  case distance_unit do
                                               "km" -> {1.60934 * radius, 0.621372736649807}
                                               _ -> {radius, 1}
                                             end
        where(query, [u,ugl], fragment("(point(?,?) <@> point(?,?))/?<?", ugl.longitude, ugl.latitude, ^longitude, ^latitude, ^multiplication_factor, ^distance))
      else
        query
      end
    end

    @options param: :gender
    filter gender(query, value, _conn) do
      # @todo this should be an exact match not ilike.
      where(query, [u], ilike(u.gender, ^"#{value}"))
    end

    @options param: :first_name
    filter first_name(query, value, _conn) do
      where(query, [u], ilike(u.first_name, ^"%#{value}%"))
    end

    @options param: :last_name
    filter last_name(query, value, _conn) do
      where(query, [u], ilike(u.last_name, ^"%#{value}%"))
    end

    filter is_friend(query, value, _conn) do
      query
    end

    filter is_local(query, value, _conn) do
      local_radius = JetzyModule.SearchConfigurationModule.is_local_radius()
      query
      |> where([u, ugl], fragment("(point(?,?) <@> point(?,?))<=?", ugl.longitude, ugl.latitude, u.longitude, u.latitude, ^local_radius))
    end

    filter is_traveler(query, value, _conn) do
      local_radius = JetzyModule.SearchConfigurationModule.is_local_radius()
      query
      |> where([u, ugl], fragment("(point(?,?) <@> point(?,?))>?", ugl.longitude, ugl.latitude, u.longitude, u.latitude, ^local_radius))
    end

    filter age_from(query, value, _conn) do
      query
      |> where([u], u.age >= ^value)
    end

    filter age_to(query, value, _conn) do
      query
      |> where([u], u.age <= ^value)
    end

    filter interest_ids(query, value, _conn) do
      value = Enum.map(value, fn x ->
        case Ecto.UUID.cast(x) do
          :error -> nil
          {:ok, v} -> v
        end
      end)
      query
      |> where([_u, _ugl, ui], ui.interest_id in ^value)
    end
  end

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # user_verification_request/2
  #----------------------------------------------------------------------------
  swagger_path :user_verification_request do
    get("/v1.0/user-verification-request")
    summary("Get User Verification Request")
    description("Extra details to help with vetting users")
    produces("application/json")
    security([%{Bearer: []}])
    response(200, "Ok", Schema.ref(:VerificationRequest))
  end
  @doc """
  Get verification request object.
  @todo move logic into Context Class to keep code dry
  """
  def user_verification_request(conn, params) do
    with %{id: user_id} = current_user <- Guardian.Plug.current_resource(conn) do
      cond do
        existing = Data.Repo.get_by(DataSchema.UserVerificationRequest, user_id: user_id) ->
          conn
          |> render("verification_request.json", admin: true, request: existing)
        :else ->
          conn
          |> put_status(404)
          |> json(%{success: false, message: "Not Found"})
      end
    else
      _ ->
        conn
        |> put_status(403)
        |> json(%{success: false, message: "Invalid Request"})
    end
  end

  #----------------------------------------------------------------------------
  # update_user_verification_request/2
  #----------------------------------------------------------------------------
  swagger_path :update_user_verification_request do
    put("/v1.0/user-verification-request")
    summary("Update User Verification Request")
    description("Extra details to help with vetting users")
    produces("application/json")
    security([%{Bearer: []}])
    response(200, "Ok", Schema.ref(:VerificationRequest))
  end
  @doc """
  Update verification request object.
  @todo move logic into Context Class to keep code dry
  """
  def update_user_verification_request(conn, params) do
    with %{id: user_id} = current_user <- Guardian.Plug.current_resource(conn) do
      cond do
        existing = Data.Repo.get_by(Data.Schema.UserVerificationRequest, user_id: user_id) ->
          now = DateTime.utc_now()
          record = conn.body_params
                   |> SecureX.Helper.keys_to_atoms()
                   |> update_in([:updated_at], &(&1 || now))
          record = (if Map.has_key?(record, :email_preference) do
                      record
                      |> update_in([:email_preference], &(&1 && String.to_existing_atom(&1)))
                    else
                      record
                    end)
          with {:ok, record} <- Data.Context.update(Data.Schema.UserVerificationRequest, existing, record) do
            conn
            |> render("verification_request.json", request: record)
          else
            _ ->
              conn
              |> put_status(403)
              |> json(%{success: false, code: :update_failed, message: "Update Failed"})
          end
        :else ->
          now = DateTime.utc_now()
          record = conn.body_params
                   |> SecureX.Helper.keys_to_atoms()
                   |> put_in([:approval_status], :pending)
                   |> put_in([:inserted_at], now)
                   |> update_in([:updated_at], &(&1 || now))
                   |> update_in([:email_preference], &(&1 && String.to_existing_atom(&1)))
          with {:ok, record} <- Data.Context.create(Data.Schema.UserVerificationRequest, record) do
            conn
            |> render("verification_request.json", request: record)
          else
            _ ->
              conn
              |> put_status(403)
              |> json(%{success: false, code: :update_failed, message: "Update Failed"})
          end
      end
    else
      _ ->
        conn
        |> put_status(403)
        |> json(%{success: false, code: :auth_error, message: "Invalid Request"})
    end
  end

  #----------------------------------------------------------------------------
  # sign_in/2
  #----------------------------------------------------------------------------
  swagger_path :sign_in do
    post("/v1.0/sign-in")
    summary("SignIn")
    description("SignIn with email and password")
    produces("application/json")
    parameters do
      body(:body, Schema.ref(:SignIn), "SignIn Params", required: true)
    end
    response(200, "Ok", Schema.ref(:User))
  end

  @doc """
  sign_in (only active users)
  @todo we need to track login dates / activity dates to track returning users.
  """
  def sign_in(conn, %{"login" => login, "password" => password} = params) do
    handle_sign_in(conn, params)
  end

  #----------------------------------------------------------------------------
  # direct_sign_in/2
  #----------------------------------------------------------------------------
  swagger_path :direct_sign_in do
    post("/v1.0/direct-sign-in")
    summary("DirectSignIn")
    description("SignIn without password")
    produces("application/json")
    parameters do
      body(:body, Schema.ref(:DirectSignIn), "SignIn Params", required: true)
    end
    response(200, "Ok", Schema.ref(:User))
  end

  @doc """
  direct_sign_in (only active users)
  """
  def direct_sign_in(conn, %{"user_id" => user_id} = params) do
    handle_sign_in(conn, params)
  end

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post("/v1.0/sign-up")
    summary("User Signup")
    description("Signup the User with the params in the body. if you set is_referral=false, then you dont need any referral code. ")
    produces("application/json")
    parameters do
      body(:body, Schema.ref(:SignUp), "Signup the User with the params in the body. if you set is_referral=false, then you dont need any referral code", required: true)
    end
    response(200, "Ok", Schema.ref(:User))
  end

  @doc """
  sign_up with or without referral code
  """
  def create(conn, params) do
    case create_user(conn, params) do
      {:error, :deleted} ->
        conn
        |> put_status(409)
        |> json(%{success: false, message: "The account is deleted"})
      {:error, :deactivated} ->
        conn
        |> put_status(409)
        |> json(%{success: false, message: "The account against this email is deactivated. If you would like to reactivate please email us at contact@jetzyapp.com"})
      {:error, :self_deactivated} ->
        conn
        |> put_status(409)
        |> json(%{success: false, message: "The account against this email is temporary deactivated. Login with your password to continue"})
      {:error, :exists} ->
        conn
        |> put_status(409)
        |> json(%{success: false, message: "This email is already registered"})
      {:ok, %{jwt: token, user: user}} ->
        conn |> render("jwt.json", jwt: token, user: user)
      {:ok, %{user: user, message: message}} ->
        conn |> put_status(200) |> render("user.json", user: user, message: message)
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "error.json", %{error: Common.decode_changeset_errors(changeset)})
      {:error, message} ->
        conn
        |> put_status(422)
        |> json(%{
          success: false,
          errors: message
        })

    end

  end

  def create_user(conn, params) do
    context = Noizu.ElixirCore.CallingContext.system()
    # pri-0, this is a security risk. included for backwards compatibility. - keith brings
    options = cond do
                params["role"] -> [role: params["role"]]
                :else -> []
              end
    with {:ok, {user, params}} <- Users.register_user(params, context, options),
         {:ok, _} <- User.create_user_installs(user, params),
         {:ok, token, _} <- Guardian.encode_and_sign(user),
         {:ok, _} <- params["installs"] && User.create_user_installs(user, Map.merge(params["installs"], %{"current_jwt" => token})) || {:ok, :nothing}
      do
      # Sign Up Points
      ApiWeb.Utils.Common.update_points(user.id, :sign_up_1000)

      # Update Analytics
      Jetzy.Module.Telemetry.Analytics.user_registration(conn, user)

      # Transfer existing user interests if guest account exists
      # todo move this into GuestInterests module - keith brings.
      if !is_nil(params["installs"]) do
        %{"installs" => %{"device_token" => device_token}} = params
        create_user_interests(user.id, device_token)
        Task.start(fn -> GuestInterests.delete_guest_interests_by_device_id(device_token) end)
      end

      # Schedule Push notification if incomplete profile
      if User.incomplete_profile?(user) do
        ApiWeb.Utils.PushNotification.schedule_push_notification(:profile_reminder, user)
      end

      # response
      {:ok, %{jwt: token, user: user}}
    else
      {:ok, %{user: user, message: message}} ->
        {:ok, %{user: user, message: message}}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:error, changeset}

      {:error, message} ->
        {:error, message}
    end
  end

  #----------------------------------------------------------------------------
  # complete_signup/2
  #----------------------------------------------------------------------------
  swagger_path :complete_signup do
    post("/v1.0/complete-signup")
    summary("Complete signup for invited user")
    description("Complete signup for invited user. User needs to add first and last name with the profile picture(base 64 encoded).")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:CompleteSignup), "Complete signup for invited user. User needs to add first and last name with the profile picture(base 64 encoded).", required: true)
    end

    response(200, "Ok", Schema.ref(:User))
  end

  @doc """
  complete signup process.
  """
  def complete_signup(conn, params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    current_jwt = conn.private[:guardian_default_token]
    reward_id = "233a3935-f56b-440c-8f75-2f97a15a549f"
    blur_hash = nil
    # {user_image, user_thumb, blur_hash} = Users.upload_profile_image_extended(params)
    params = if Map.has_key?(params, "gender") do
               gender = String.downcase(params["gender"])
               Map.merge(params, %{"gender" => gender})
             else
               params
             end
    with %User{image_name: user_image} = user <- Context.get(User, user_id),
      params <- check_profile_image_for_complete_signup(user_image, params) do
      case Users.update(user, params) do
        {:ok, updated_user} ->
          case params do
            %{"first_name" => _first_name, "last_name" => _last_name} ->
              #ApiWeb.Utils.Common.update_points(user.id, :sign_up_1000)
              :no_need_to_update_points # Performed by create account step and social login.
            _ -> "no need to update points"
          end
          if Map.has_key?(params, "image_name") && Map.has_key?(params, "small_image_name") do
            {user_image, user_thumb} = {params["image_name"], params["small_image_name"]}
            !is_nil(user_image) && User.create_user_profile_image_extended(user, {nil, user_image, user_thumb, blur_hash}, 1)
          end
          updated_user = add_more_fields(updated_user)
                         |> Map.put(:jwt, current_jwt )
          Api.Workers.StopJob.stop_oban_job("Api.Workers.PushNotificationSignupWorker")
          Jetzy.Module.Telemetry.Analytics.user_registration_complete(conn, updated_user)

          render(conn, "user_profile.json", %{
            user: updated_user,
            current_user_id: updated_user.id
          })

        {:error, error} ->
          render(conn, "user_profile_update.json", error: error)
      end

    else
      {:error, error} -> render(conn, "user_profile_update.json", error: error)
    end
  end

  #----------------------------------------------------------------------------
  # update/2
  #----------------------------------------------------------------------------
  swagger_path :update do
    post("/v1.0/user")
    summary("Update User Password")
    description("Update User Password")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      body(:body, Schema.ref(:UpdateUserPassword), "Update Params", required: true)
    end

    response(200, "Ok", Schema.ref(:User))
  end

  @doc """
  Update user password.
  @todo use better name. Update would refer to updating any part of user in usual RESTful idiomic usage.
  """
  def update(conn, %{"old_password" => old_password, "new_password" => new_password}) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)

    case Context.get(User, user_id) do
      nil ->
        conn
        |> put_status(401)
        |> render("unauthorized.json", message: "Invalid User")

      %User{} = user ->
        case Users.check_password(user, old_password) do
          {:error, _error} ->
            conn
            |> put_status(401)
            |> render("unauthorized.json", message: "Invalid Password")

          {:ok, _, _} ->
            case Context.update(User, user, %{password: hash_pwd_salt(new_password)})  do
              {:ok, updated_user} ->
                render(conn, "user.json", %{user: updated_user, message: "Password Updated Successfully"})

              {:error, _error} ->
                conn
                |> put_status(401)
                |> render("unauthorized.json", message: "Unable To Change Password")
            end
        end

      _ ->
        conn
        |> put_status(401)
        |> render("unauthorized.json", message: "Something Went Wrong")
    end
  end

  #----------------------------------------------------------------------------
  # request_admin_to_reactivate_account/2
  #----------------------------------------------------------------------------
  swagger_path :request_admin_to_reactivate_account do
    post("/v1.0/request-reactivate-account")
    summary("Request admin for account reopening if it got deactivated")
    description("Send email to admin if a user's account gets deactivated due to a report by another user")
    produces("application/json")
    parameters do
      body(:body, Schema.ref(:RequestAdmin), "Send Mail to admin", required: true)
    end
    response(200, "Ok", Schema.ref(:UserEmailResponse))
  end

  @doc """
  Send email to admin to request account reactivation.
  @todo email or admin panel message queue?
  """
  #For the time sake, we are assuming that deactivated account is that whose is_deleted flag is true
  def request_admin_to_reactivate_account(conn, %{"user_email" => user_email, "description" => description} = _params) do
    with %{id: _user_id, is_deactivated: is_deactivated, is_deleted: is_deleted, first_name: fname,
           last_name: lname} <- Context.get_by(User, [email: user_email]),
         true <- is_deleted,
         #         true <- is_deactivated,
         {:ok, _} <- Api.Mailer.send_account_reactivation_email(%{description: description,
           from_email: user_email, user_name: fname <> " " <> lname}) do
      render(conn, "message.json", %{message: "Email Sent Successfully"})
    else
      nil -> render(conn, "error.json", %{error: "User not found"})
      #      true -> render(conn, "error.json", %{error: "The Account has been Deleted"})
      false -> render(conn, "error.json", %{error: "The requested account is NOT deactivated"})
      {:error, error} -> render(conn, "error.json", %{error: error})
      _ -> render(conn, "error.json", %{error: "Something went wrong"})
    end
  end
  def request_admin_to_reactivate_account(conn, _) do
    render(conn, "error.json", %{error: "Invalid Params"})
  end

  #----------------------------------------------------------------------------
  # add_user_profile_image/2
  #----------------------------------------------------------------------------
  swagger_path :add_user_profile_image do
    post("/v1.0/add-user-image")
    summary("Add User Profile Image")
    description("User will be able to upload a base 64 encoded image")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:UserImage), "base 64 URL of image for add user profile image", required: true)
    end

    response(200, "Ok", Schema.ref(:UserImageResponse))
  end

  @doc """
  Upload Image of a User
  """
  def add_user_profile_image(conn, %{"image" => _image_name} = params) do
    %{id: user_id} = current_user = Api.Guardian.Plug.current_resource(conn)
    params = Map.put(params, "user_id", user_id)

    {user_image, user_thumb, blur_hash} = JetzyModule.AssetStoreModule.upload_if_image_extended(params, "image", "user")
    params = Map.merge(params, %{"images" => user_image, "small_images" => user_thumb, "blur_hash" => blur_hash})

    with order_number when is_number(order_number) <- UserImages.get_by_user_id(user_id) do
      order_number = order_number + 1
      params = Map.put(params, "order_number", order_number)

      with {:ok, %UserImage{} = user_image} <- Context.create(UserImage, params),
           {:ok, _} <- Users.update(current_user, %{image_name: user_image.images, small_image_name: user_thumb, blur_hash: blur_hash}) do
        conn
        |> put_view(ApiWeb.Api.V1_0.UserImageView)
        |> render("create_user_image.json", %{user_image: user_image})

      else
        {:error, error} -> put_view(conn, ApiWeb.Api.V1_0.UserImageView)
                           |> render("user_image.json", %{error: error})
        _ -> put_view(conn, ApiWeb.Api.V1_0.UserImageView)
             |> render("user_image.json", %{error: "Something went wrong"})
      end
    else
      nil ->
        conn
        |> put_view(ApiWeb.UserImageView)
        |> render("user_image.json", %{error: "User Image does not exist!"})
    end
  end

  #----------------------------------------------------------------------------
  # delete_user_profile_image\2
  #----------------------------------------------------------------------------
  swagger_path :delete_user_profile_image do
    PhoenixSwagger.Path.delete("/v1.0/delete-user-image")
    summary("Delete Profile Image")
    description("You can delete profile image")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      image_id(:query, :string, "Profile Image ID", required: true)
    end

    response(200, "Ok", %{status: "Profile Image Deleted"})
  end

  @doc """
  Delete a user profile image.
  """
  def delete_user_profile_image(conn, %{"image_id" => image_id} = _params) do
    %User{id: user_id} = user = Guardian.Plug.current_resource(conn)

    with %UserImage{} = user_image <- Context.get(UserImage, image_id) do
      counte_images = user |> Ecto.assoc(:user_images) |> Repo.aggregate(:count, :id)
      if(counte_images > 1) do
        Context.update(UserImage, user_image, %{is_deleted: true, deleted_at: DateTime.utc_now()})
        candidate = UserImage |> where([ui], ui.user_id == ^user_id and ui.is_deleted == false)|> order_by([ui], desc: ui.order_number) |> first() |> Repo.one()
        Context.update(User, user, %{image_name: candidate.images, small_image_name: candidate.small_images})
        # json(conn, %{ResponseData: %{status: "Profile Image Deleted"}})
        render(conn, "delete.json", %{message: "Profile Image Deleted Successfully"})
      else
        conn
        |> put_view(ApiWeb.Api.V1_0.UserImageView)
        |> render("user_image.json", %{error: "Last profile image cannot be deleted"})
      end
    else
      nil ->
        conn
        |> put_view(ApiWeb.Api.V1_0.UserImageView)
        |> render("user_image.json", %{error: "Profile Image not found"})
      {:error, error} -> render(conn, "user_image.json", %{error: error})
    end
  end

  #----------------------------------------------------------------------------
  # sort_profile_images/2
  #----------------------------------------------------------------------------
  swagger_path :sort_profile_images do
    put("/v1.0/sort-profile-images")
    summary("Set Default User Profile Image from many")
    description("Set Default User Profile Image from many")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:SortProfileImages), "Sort Profile Images", required: true)
    end

    response(200, "Ok", Schema.ref(:UserImageResponse))
  end

  @doc """
  Set Default User Profile Image from many.
  """
  def sort_profile_images(conn, %{"image_ids" => image_ids}) do
    %{id: user_id} = current_user = Api.Guardian.Plug.current_resource(conn)
    order_number = UserImages.get_by_user_id(user_id)
    if(Enum.count(image_ids)>0) do
      #reverse sort the list
      image_ids = Enum.reverse(image_ids)

      Enum.reduce(image_ids, [order_number], fn image_id, acc ->
        [order_number|_] = acc
        set_profile_image_order(image_id, order_number+1)
        [order_number+1]
      end)

      # make last item as default image ie user.image_name
      image_id = List.last(image_ids)
      profile_image = Context.get_by(UserImage, [id: image_id])
      if !is_nil(profile_image) do
        Users.update(current_user, %{image_name: profile_image.images, small_image_name: profile_image.small_images})
        profile_images =
          UserImage
          |> where([ui], ui.user_id == ^user_id)
          |> order_by([ui], desc: ui.order_number)
          |> Repo.all()

        conn
        |> put_view(ApiWeb.Api.V1_0.UserImageView)
        |> render("user_images.json", %{user_images: profile_images})
      else
        conn
        |> put_view(ApiWeb.Api.V1_0.UserImageView)
        |> render("user_image.json", %{error: ["No Image Found"]})
      end
    else
      conn
      |> put_view(ApiWeb.Api.V1_0.UserImageView)
      |> render("user_image.json", %{error: ["No Image Found"]})
    end
  end

  #----------------------------------------------------------------------------
  # validate_referral/2
  #----------------------------------------------------------------------------
  swagger_path :validate_referral do
    post("/v1.0/validate-referral-code")
    summary("Validate Invite Code")
    description("Validates if invite code is correct")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:InviteCode), "Invite Code Params", required: true)
    end

    response(200, "Ok", Schema.ref(:InviteCodeResponse))
  end


  @doc """
  validate referral code
  """
  def validate_referral(conn, %{"referral_code" => referral_code} = _params) do
    case Users.validate_referral_code(referral_code) do
      true ->
        conn
        |> put_status(200)
        |> json(%{
          success: true,
          message: "Invite code is verified."
        })

      false ->
        conn
        |> put_status(200)
        |> json(%{
          success: false,
          message: "Invalid invite code."
        })
    end
  end

  #----------------------------------------------------------------------------
  # verify_user_image/2
  #----------------------------------------------------------------------------
  swagger_path :verify_user_image do
    post("/v1.0/verify-user-image")
    summary("Verify User Image")
    description("User will be able to upload a base 64 encoded image for verification")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:VerifyUserImage), "base 64 URL of image for verify user image", required: true)
    end

    response(200, "Ok", Schema.ref(:VerifyUserImageResponse))
  end

  @doc """
  Verify User Image
  """
  def verify_user_image(conn, %{"image" => image} = params) do
    # Get current user information using conn
    %User{} = user = Guardian.Plug.current_resource(conn)
    image_bucket = JetzyModule.AssetStoreModule.image_bucket()
    base_url = JetzyModule.AssetStoreModule.image_base_url()
    with {:ok, image_binary} <- String.split(image, ",") |> Enum.at(1) |> Base.decode64() do
      image_name = JetzyModule.AssetStoreModule.upload_if_image(params, "image", "user")
      updated_user = with {:ok, updated_user} <- Users.update(user, %{"user_verification_image" => image_name, "is_selfie_verified" => false}) do
                       add_more_fields(updated_user)
                     end

      render(conn, "user_profile.json", %{user: updated_user, current_user_id: user.id})
    else
      {:error, error} ->
        conn
        |> render("error.json", %{error: error})
      _ ->
        render(conn, "error.json", %{error: "Something went wrong"})
    end
  end

  #----------------------------------------------------------------------------
  # update_profile/2
  #----------------------------------------------------------------------------
  swagger_path :update_profile do
    post("/v1.0/user-profile-update")
    summary("Update User Profile")
    description("Update user by changing the gender and other params according to your profile.")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:UpdateUserProfile), "Update User Profile Params", required: true)
    end

    response(200, "Ok", Schema.ref(:User))
  end

  @doc """
  Update User Profile
  """
  def update_profile(conn, params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)

    with %User{} = user <- Context.get(User, user_id),
    :ok <- params["referral_code"] && check_referral_code_availability(params["referral_code"], user_id) || :ok do
      params = cond do
                 params["referral_code"] -> Map.put(params, "jetzy_exclusive_status", :approved)
                 :else -> params
               end
      case Users.update(user, params) do
        {:ok, updated_user} ->
          updated_user = add_more_fields(updated_user)
          if Map.has_key?(params, "latitude") && Map.has_key?(params, "longitude") do
            case Context.get_by(UserGeoLocation, [user_id: user_id]) do
              nil ->
                Context.create(
                  UserGeoLocation,
                  %{user_id: user_id, latitude: params["latitude"], longitude: params["longitude"]}
                )
                Context.create(
                  UserGeoLocationLog,
                  %{user_id: user_id, latitude: params["latitude"], longitude: params["longitude"]}
                )
              %UserGeoLocation{} = ugl ->
                Context.update(UserGeoLocation, ugl, %{latitude: params["latitude"], longitude: params["longitude"]})
                Context.create(
                  UserGeoLocationLog,
                  %{user_id: user_id, latitude: params["latitude"], longitude: params["longitude"]}
                )
              _ -> :do_nothing
            end
          end

          if Map.has_key?(params, "referral_code") do
            Context.create(UserReferralCodeLog, %{referral_code: user.referral_code, user_id: user_id})
            # Log auto approval if referral is not false.
            if params["referral_code"] do
              log = %Data.Schema.UserApprovalLog{
                user_id: user.id,
                approval_source: :auto,
                approval_status: :approved
              }
              Data.Repo.insert(log)
            end
          end

          render(conn, "user_profile.json", %{
            user: updated_user,
            current_user_id: updated_user.id
          })

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "user_profile_update.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
      end
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "user_profile_update.json", %{error: ApiWeb.Utils.Common.decode_changeset_errors(changeset)})
        :error ->
          render(conn, "user_profile_update.json", %{error: ["referral_code has already been taken"]})
    end
  end

  #----------------------------------------------------------------------------
  # logout/2
  #----------------------------------------------------------------------------
  swagger_path :logout do
    get("/v1.0/logout")
    summary("Logout")
    description("Logout")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      device_token :query, :string, "Device Token", required: true
    end
    response(200, "Ok", Schema.ref(:User))
    security([%{Bearer: []}])
  end

  @doc """
  Log active user out.
  """
  def logout(conn, params) do
    ["Bearer " <> token] = get_req_header(conn, "authorization")

    with user_installs when not is_nil(user_installs) <- UserInstalls.get_user_installs_by_device_token(params["device_token"])
      do
      if not is_nil(user_installs), do: Context.delete(user_installs)
      conn
      |> put_status(200)
      |> json(%{
        success: true,
        message: "Successfully logged out.",
        result: []
      })
    else
      {:error, error} ->
        conn
        |> put_status(401)
        |> json(%{
          success: false,
          message: Common.decode_changeset_errors(error),
          result: []
        })

      nil ->
        conn
        #            |> put_status(401)
        #            |> json(%{
        #              success: false,
        #              message: "No login found on this device",
        #              result: []
        #            })
        conn
        |> put_status(200)
        |> json(%{
          success: true,
          message: "Successfully logged out.",
          result: []
        })
      _ ->
        conn
        |> put_status(401)
        |> json(%{
          success: false,
          message: "Something went wrong",
          result: []
        })
    end

  end

  #----------------------------------------------------------------------------
  # forget_password/2
  #----------------------------------------------------------------------------
  swagger_path :forget_password do
    post("/v1.0/forget-password")
    summary("ForgetPassword")
    description("ForgetPassword with email and new password")
    produces("application/json")

    parameters do
      body(:body, Schema.ref(:ForgetPassword), "ForgetPassword Params", required: true)
    end

    response(200, "Ok", Schema.ref(:User))
  end

  @doc """
  Start forgot password process.
  """
  def forget_password(conn, %{"email" => email, "otp_code" => otp, "password" => password}) when otp != "" do
    otp = if is_binary(otp) do String.to_integer(otp) else otp end
    case Users.get_user_by_email(email) do
      nil ->
        conn
        |> put_status(401)
        |> render("unauthorized.json", message: "User Does not Exist")
      %User{id: user_id} = user ->
        case Context.get_by(OTPToken, user_id: user_id) do
          nil ->
            conn
            |> put_status(401)
            |> render("error.json", message: "Assign an OTP First")
          %OTPToken{otp: otp_code} = otp_token when otp_code == otp ->
            case Context.update(User, user, %{password: hash_pwd_salt(password)}) do
              {:ok, user} ->
                Context.update(OTPToken, otp_token, %{last_forget_password_at: DateTime.utc_now})
                user = add_more_fields(user)
                conn
                |> put_status(200)
                  #                |> render("user.json", user: user, message: "Your Password has been changed Successfully")
                |> render("user_profile.json", %{user: user, current_user_id: user.id})
              {:error, _error} ->
                conn
                |> put_status(401)
                |> render("unauthorized.json", message: "Unable To Change Password")
            end
          _ ->
            conn
            |> put_status(401)
            |> render("error.json", error: "Invalid OTP")
        end
    end
  end

  def forget_password(conn, %{"email" => email}) do
    case Data.Context.OTPTokens.create_request(email) do
      {:ok, {user, otp_token}} ->
        case Api.Mailer.send_forget_password_email(user, "#{otp_token.otp}") do
          {:error, _} -> render(conn, "forget.json", %{message: "Error in sending email"})
          {:ok, _} -> render(conn, "forget.json", %{message: "Email Sent"})
        end
      {:error, :not_found} ->
        conn
        |> put_status(401)
        |> render("unauthorized.json", message: "User Does not Exist")
      {:error, _} ->
        conn
        |> put_status(401)
        |> render("error.json", error: "Unable To Create OTP")
    end
  end

  #----------------------------------------------------------------------------
  # show/1
  #----------------------------------------------------------------------------
  swagger_path :show do
    get("/v1.0/user-profile/{id}")
    summary("Get User By ID")
    description("Get User By ID")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      id :path, :string, "User ID", required: true
    end
    response(200, "Ok", Schema.ref(:User))
  end

  @doc """
  Get user by id.
  """
  def show(conn, %{"id" => profile_id}) do
    %{id: current_user_id} = active_user = Guardian.Plug.current_resource(conn)
    with %{is_deactivated: is_deactivated, is_self_deactivated: is_self_deactivated, is_deleted: is_deleted} = user <- Context.get(User, profile_id) |> Users.preload_all(),
         nil <- Context.get_by(UserBlock, [user_from_id: current_user_id, user_to_id: profile_id, is_blocked: true]),
          # {:ok, %User{} = user } <- check_is_deleted(user),
          # {:ok, %User{} = user } <- check_is_deactivated(user),
         false <- is_deleted or is_deactivated or is_self_deactivated do
      user = add_more_fields(user)
             |> get_follow_status(profile_id, current_user_id)
             |> Data.Schema.User.set_chat_settings(active_user)
      render(conn, "user_profile.json", %{user: user, current_user_id: current_user_id})
    else
      nil -> render(conn, "user_profile.json", %{error: ["User does not exist"]})
      {:error, message} ->
        conn
        |> put_status(422)
        |> json(%{
          success: false,
          errors: message
        })
      true ->
        conn
        |> put_status(422)
        |> json(%{
          success: false,
          errors: "The requested account is deleted or deactivated"
        })
      %UserBlock{} = _user_block -> render(conn, "user_profile.json", %{error: "The current user is blocked"})
      _ -> render(conn, "user_profile.json", %{error: "Something went wrong"})
    end
  end

  #----------------------------------------------------------------------------
  # invite_user\2
  #----------------------------------------------------------------------------
  swagger_path :invite_user do
    post("/v1.0/invite-user")
    summary("User Invite")
    description("Invite user with referral code by giving email in the body of that user.")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:InviteUser), "Invite user with referral code by giving email in the body of that user.", required: true)
    end

    response(200, "Ok", Schema.ref(:InviteUser))
  end

  @doc """
  invite user with referral code
  """
  def invite_user(conn, %{"referred_to" => referred_to}) do
    %{id: user_id, first_name: first_name, referral_code: referral_code} = Guardian.Plug.current_resource(conn)
    user = %{email: referred_to, first_name: first_name}
    email_params = %{"url" => "#{@referral_code_url}#{referral_code}",
      "referral_code" => referral_code, "first_name" => first_name}

    with nil <- UserReferrals.get_by(referred_to, user_id),
         {:ok , _pid} <- Api.Mailer.send_invite_user_referral_code(user, email_params),
         {:ok, _user_referral} <-
           Context.create(UserReferral, %{
             "referred_to" => referred_to,
             "referred_from_id" => user_id,
             "referral_code" => referral_code
           }) do
      Data.Context.UserReferrals.check_is_refferal_by_email__clear_cache(referred_to)
      conn
      |> put_status(200)
      |> json(%{
        success: true,
        message: "Referral Code Sent Successfully.",
        result: %{"referral_code" => referral_code}
      })
    else
      %UserReferral{} = _user_referral ->
        Api.Mailer.send_invite_user_referral_code(user, email_params)
        conn
        |> put_status(200)
        |> json(%{
          success: true,
          message: "Referral Code Sent Successfully.",
          result: %{"referral_code" => referral_code}
        })

      {:error, ch} ->
        ch
    end
  end

  @doc """
  invite list of users by list of emails
  """
  def invite_user(conn, %{"emails" => emails}) do
    %{id: user_id, first_name: first_name, referral_code: referral_code} = Guardian.Plug.current_resource(conn)
    email_params = %{
      "url" => "#{@referral_code_url}#{referral_code}",
      "referral_code" => referral_code,
      "first_name" => first_name
    }

    statuses =
    for referred_to <- emails do
      user = %{email: referred_to, first_name: first_name}

      with nil <- UserReferrals.get_by(referred_to, user_id),
          {:ok , _pid} <- Api.Mailer.send_invite_user_referral_code(user, email_params),
          {:ok, _user_referral} <-
            Context.create(UserReferral, %{
              "referred_to" => referred_to,
              "referred_from_id" => user_id,
              "referral_code" => referral_code
            }) do
        Data.Context.UserReferrals.check_is_refferal_by_email__clear_cache(referred_to)
        :ok
      else
        %UserReferral{} = _user_referral ->
          Api.Mailer.send_invite_user_referral_code(user, email_params)
          :ok

        {:error, ch} ->
          ch
      end
    end
    
    conn
    |> put_status(200)
    |> json(%{
      success: true,
      message: "Referral Code Sent Successfully.",
      result: %{"referral_code" => referral_code}
    })
  end

  #----------------------------------------------------------------------------
  # update_status\2
  #----------------------------------------------------------------------------
  swagger_path :update_status do
    post("/v1.0/update-status")
    summary("User Update Status")
    description("Admin Update user Status")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:UpdateStatus), "Update Status Params", required: true)
    end

    response(200, "Ok", Schema.ref(:UpdateStatus))
  end

  @doc """
    Admin change user status to active
  """
  def update_status(conn, %{"email" => email}) do
    case Users.get_user_by_email(email) do
      nil ->
        conn
        |> put_status(401)
        |> json(%{
          success: false,
          message: "User not found",
          result: []
        })

      user ->
        Context.update(User, user, %{"is_active" => true})
        Api.Mailer.send_direct_login_email(user)
        conn
        |> put_status(200)
        |> json(%{
          success: true,
          message: "user activated",
          result: []
        })
    end
  end

  #----------------------------------------------------------------------------
  # nearby_users\2
  #----------------------------------------------------------------------------
  swagger_path :nearby_users do
    post("/v1.0/nearby-users")
    summary("Nearby Users")
    description("Nearby Users")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      body(:body, Schema.ref(:NearbyUser), "Nearby User Params", required: true)
    end

    response(200, "Ok", Schema.ref(:NearbyUserList))
  end

  @doc """
  Find nearby users.
  """
  def nearby_users(conn, params) do
    with pagination <- Common.get_pagination(params),
         %{id: user_id} <- Guardian.Plug.current_resource(conn),
         _ <- Users.create_geo_loc_and_geo_loc_log(params, user_id),
         %{latitude: latitude, longitude: longitude} <- get_lat_long(user_id, params),
         {:ok, query, _filter_values} <- apply_filters(User, conn),
         users <-
           Users.get_nearby_users(
             query,
             %{
               user_id: user_id,
               lat: latitude,
               long: longitude,
               unit: params["distance_unit"] || "miles",
               radius: params["radius"] || 1,
               is_friend: params["is_friend"] || false
             },
             pagination
           ) do
      render(conn, "nearby_users.json", %{users: users})
    end
  end

  #----------------------------------------------------------------------------
  # nearby_users_for_guest\2
  #----------------------------------------------------------------------------
  swagger_path :nearby_users_for_guest do
    post("/v1.0/guest/nearby-users")
    summary("Guest Nearby Users")
    description("Guest Nearby Users")
    produces("application/json")

    parameters do
      body(:body, Schema.ref(:NearbyUser), "Guest Nearby User Params", required: true)
    end

    response(200, "Ok", Schema.ref(:NearbyUserList))
  end

  @doc """
  Find nearby users for guest level user.
  """
  def nearby_users_for_guest(conn, params) do
    pagination = Common.get_pagination(params)
    radius = params["radius"] || 1
    latitude = params["user_latitude"] || nil
    longitude = params["user_longitude"] || nil
    distance_unit = params["distance_unit"] || "miles"

    with {:ok, query, _filter_values} <- apply_filters(User, conn),
         users <- Users.get_nearby_users_guest(query, latitude, longitude, distance_unit, radius, pagination) do
      #      entries = Context.preload_selective(users.entries, [:user_filters])
      render(conn, "nearby_users.json", %{users: users})
    end
  end

  #----------------------------------------------------------------------------
  # sync_contacts\2
  #----------------------------------------------------------------------------
  swagger_path :sync_contacts do
    post("/v1.0/sync-contacts")
    summary("User Sync Contacts")
    description("Synced Contacts and return existing and non-existing users")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:SyncContacts), "Params", required: true)
    end

    response(200, "Ok", Schema.ref(:SyncContactsResponse))
  end

  @doc """
  Sync user contacts.
  """
  def sync_contacts(conn, %{"contacts" => contacts} = _params) do
    %{id: user_id} = Guardian.Plug.current_resource(conn)

    # contact might have only mobile
    emails = contacts 
      |> Enum.map(&(&1["email"])) 
      |> Enum.filter(&(&1))
      |> Enum.uniq()  

    existing_users = Users.get_all_users_by_email(emails)
    existing_user_ids = Enum.map(existing_users, &(&1.id) ) |> Enum.uniq
    existing_contacts = Users.get_all_users_by_contact_email(emails, existing_user_ids)
    all_existing_users = existing_users ++ existing_contacts
    Users.create_user_contacts(contacts, user_id)

    non_existing_users = (emails -- Enum.map(all_existing_users, &(&1.email)))
                        |> Enum.map(&(%{email: &1, first_name: nil, last_name: nil, image_name: nil, user_id: nil}))
    render(conn, "sync_contacts.json", %{existing_contacts: all_existing_users, non_existing_contacts: non_existing_users})
  end

  #----------------------------------------------------------------------------
  # delete_user\2
  #----------------------------------------------------------------------------
  swagger_path :delete_user do
    PhoenixSwagger.Path.delete("/v1.0/delete-user")
    summary("Delete User")
    description("You can delete your self")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
    end
    response(200, "Ok", Schema.ref(:UserDelete))
  end

  @doc """
  Delete a user.
  """
  def delete_user(conn, _ ) do
    %User{} = user = Guardian.Plug.current_resource(conn)
    user_jwts = UserInstalls.get_saved_user(user.id)
                |> Enum.map(fn user_jwts ->
      case UserInstalls.get_user_installs_by_jwt(user.id, user_jwts) do
        %UserInstall{} = user_install ->
          r = Context.update(UserInstall, user_install, %{current_jwt: ""})
          Data.Context.UserInstalls.get_device_type_and_last_login__clear_cache(user.id)
          r
      end
    end)
    email = "del_"<>to_string(Timex.now)<>"_"<>user.email
    if length(user_jwts) > 0 do
      Context.update(User, user, %{is_deleted: true, email: email, deleted_at: DateTime.utc_now()})
      params = Map.from_struct(user) |> Map.delete(:id) |> Map.put(:user_id, user.id)
      Context.create(DeletedUser, params)
      case Context.get_by(Data.Schema.UserSocialAccount, [user_id: user.id]) do
        nil -> :do_nothing
        %Data.Schema.UserSocialAccount{} = usa ->
          Context.delete(usa)
      end
      render(conn, "delete.json", %{message: "User Deleted Successfully"})
    else
      render(conn, "error.json", %{message: "Something Went Wrong"})
    end
  end

  #----------------------------------------------------------------------------
  # user_reffered/2
  #----------------------------------------------------------------------------
  swagger_path :user_referred do
    get("/v1.0/user-referred")
    summary("Get Referred Users")
    description("Get Referred Users")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      page(:query, :integer, "Page", required: true)
    end
    response(200, "Ok", Schema.ref(:UserReferred))
  end

  @doc """
  Get referred users.
  """
  def user_referred(conn, %{"page" => page}) do
    %{id: current_user_id} = Guardian.Plug.current_resource(conn)
    data = UserReferrals.get_reffered_users_by_user_id(current_user_id, page)
    # data = Map.put(data, :entries, Users.get_all_users_by_email(data.entries))
    render(conn, "user_referred.json", %{user_referred: data})
    conn
  end

  #----------------------------------------------------------------------------
  # sync_contacts\2
  #----------------------------------------------------------------------------
  swagger_path :update_user_location do
    post("/v1.0/update-user-location")
    summary("Update User's location")
    description("Update the current location of the user")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:UpdateLocation), "Params", required: true)
    end

    response(200, "Ok", Schema.ref(:UpdatedLocation))
  end

  @doc """
  Sync user contacts.
  """
  def update_user_location(conn, %{"latitude" => latitude, "longitude" => longitude} = params) do
    %{id: current_user_id} = Guardian.Plug.current_resource(conn)
    params = Map.put(params, "user_id", current_user_id)
    with nil <- Context.get_by(UserGeoLocation, [user_id: current_user_id]),
         {:ok, %UserGeoLocation{}} <- Context.create(UserGeoLocation, params),
         {:ok, %UserGeoLocationLog{}} <- Context.create(UserGeoLocationLog, params) do
      render(conn, "message.json", %{message: "User location updated successfully"})

    else
      %UserGeoLocation{} = ugl ->
        with {:ok, %UserGeoLocation{}} <- Context.update(UserGeoLocation, ugl, params),
             {:ok, %UserGeoLocationLog{}} <- Context.create(UserGeoLocationLog, params) do
          render(conn, "message.json", %{message: "User location updated successfully"})
        else
          _ -> render(conn, "error.json", %{message: "Something went wrong"})
        end

      _ -> render(conn, "error.json", %{message: "Something went wrong"})
    end
  end

  def update_user_location(conn, _params) do
    render(conn, "error.json", %{message: "You should have to enter latitude and longitude"})
  end

  #----------------------------------------------------------------------------
  # delete_guest_account\2
  #----------------------------------------------------------------------------
  swagger_path :delete_guest_account do
    delete("/v1.0/guest/{device_token}/preferences")
    summary("Record User Feedback")
    description("Record User Feedback")
    produces("application/json")
    parameters do
      device_token :path, :string, "Device ID", required: true
    end
  end

  @doc """
  Delete Guest Account Data.
  """
  def delete_guest_account(conn, %{"device_token" => device_token}) do
    GuestInterests.delete_guest_interests_by_device_id(device_token)
    conn
    |> put_status(200)
    |> json(%{success: true, code: 200, message: nil, response: %{}})
  rescue _ ->
    conn
    |> put_status(500)
    |> json(%{success: false, code: 500, message: "Unable to complete request. Please try again later.", response: %{}})
  catch _ ->
    conn
    |> put_status(500)
    |> json(%{success: false, code: 500, message: "Unable to complete request. Please try again later.", response: %{}})
  end

  #----------------------------------------------------------------------------
  # log_user_feedback\2
  #----------------------------------------------------------------------------
  swagger_path :log_user_feedback do
    put("/v1.0/active-user/feedback")
    summary("Record User Feedback")
    description("Record User Feedback")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
    end
  end

  @doc """
  Log user feedback.
  """
  def log_user_feedback(conn, _) do
    %{id: current_user_id} = user = Guardian.Plug.current_resource(conn)
    conn
    |> put_status(200)
    |> json(%{success: true, code: 200, message: nil, response: %{}})
  end

  #----------------------------------------------------------------------------
  # begin_account_deletion\2
  #----------------------------------------------------------------------------
  swagger_path :begin_account_deletion do
    delete("/v1.0/active-user/account")
    summary("Begin Account Deletion Process")
    description("Begin Account Deletion Process")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
    end
  end

  @doc """
  Kick off account deletion process.
  """
  def begin_account_deletion(conn, _) do
    %{id: current_user_id} = user = Guardian.Plug.current_resource(conn)
    with  {:ok, user} <- Data.Context.update(User, user, %{is_self_deactivated: true, modified_at: DateTime.utc_now()}) do
      # TODO Schedule Deletion/Review/Email. Log Feedback if any.
      context = conn.private[:context]
      #---------------
      # Prepare Token
      #---------------
      settings = %{
        type: :confirmation,
        permissions: %{view: :grant, delete: :grant},
        extended_info: %{
          unlimited_use: true,
        },
        #validity_period: {{:relative, hours: -1}, {:relative, days: 7}},
        resource: {:user, {:ref, User, user.id}},
        scope: :web
      }
      token = Noizu.SmartToken.V3.Token.Repo.new(settings)
              |> Noizu.SmartToken.V3.Token.Repo.bind!(%{recipient: user}, Noizu.ElixirCore.CallingContext.system(context), %{})
              |> Noizu.SmartToken.V3.Token.Entity.encoded_key()

      recipient = %{ref: {:ref, User, user.id}, name: "#{user.last_name}, #{user.first_name}", email: user.email}
      recipient_email = user.email
      template = Noizu.EmailService.V3.Email.Template.Entity.entity!({:jetzy, :confirm_delete})
                 |> Noizu.EmailService.V3.Email.Template.Entity.refresh!(Noizu.ElixirCore.CallingContext.system(context))
      bindings = %{
        user:  %{
          id: user.id,
          profile_picture: "your-image.png",
          name: %{
            first: user.first_name,
            last: user.last_name
          },
          email: user.email,
        },
        environment: %{
          locale: "en",
          website: @sendgrid_website,
          cdn: @sendgrid_cdn,
          contact: %{
             email: "contact@jetzy.com",
             name: %{
                first: "Contact",
                last: "Jetzy"
             }
          }
        },
        smart_token: token
      }
      send_options = %{}

      #---------------
      # Deliver
      #---------------

      outcome = %Noizu.EmailService.V3.SendGrid.TransactionalEmail{
                  template: Noizu.Proto.EmailServiceTemplate.refresh!(template, context),
                  recipient: recipient,
                  recipient_email: recipient_email,
                  sender: %{name: "Jetzy", email: "support@account.jetzy.com", ref: {:ref, User, :system}},
                  reply_to: %{name: "Jetzy", email: "support@account.jetzy.com", ref: {:ref, User, :system}},
                  body: " ",
                  html_body: " ",
                  subject: " ",
                  bindings: bindings,
                } |> Noizu.EmailService.V3.SendGrid.TransactionalEmail.send!(context, send_options)
      outcome = case outcome do
                  {:error, _} -> outcome
                  _ ->
                    case outcome.binding.state do
                      {:error, details} -> {:error, {details, Noizu.ERP.ref(outcome)}}
                      :ok -> {:ok, Noizu.ERP.ref(outcome)}
                    end
                end

      with {:ok, _} <- outcome do
        conn
        |> put_status(200)
        |> json(%{success: true, code: 200, message: "Account deactivated", response: %{}})
      else
        error ->
          Logger.error("[Account] Delete Email Failure: #{inspect error}")
          conn
          |> put_status(500)
          |> json(%{success: true, code: 125, message: "Unable to Send Confirmation. Please Contact Support", response: %{}})
      end
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(422)
        |> json(%{success: false, code: 124, messsage: Common.decode_changeset_errors(changeset)})
    end
  end



  #----------------------------------------------------------------------------
  # deactivate_user_account\2
  #----------------------------------------------------------------------------
  swagger_path :deactivate_user_account do
    put("/v1.0/deactivate-user-account")
    summary("Deactivate user's account")
    description("Deactivate user's account")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
    end
  end

  @doc """
  Deactivate a user's account
  """
  def deactivate_user_account(conn, _) do
    %{id: current_user_id, is_self_deactivated: is_self_deactivated, is_deactivated: is_deactivated} = user = Guardian.Plug.current_resource(conn)
    with  false <- is_self_deactivated,
          {:ok, _user} <- Data.Context.update(User, user, %{is_self_deactivated: true}) do
      conn
      |> put_status(200)
      |> json(%{success: true, message: "Account deactivated"})
    else
      true ->
        conn
        |> put_status(422)
        |> json(%{success: false, messsage: "Your account is already deactivated"})
        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> put_status(422)
          |> json(%{success: false, messsage: Common.decode_changeset_errors(changeset)})
    end
  end

  #============================================================================
  # Internal Methods
  #============================================================================

  defp set_profile_image_order(image_id, order_number, set_default \\ false) do
    UserImage
    |> where([ui], ui.id == ^image_id and ui.is_deleted == false)
    |> update([ui], [set: [order_number: ^order_number]])
    |> Repo.update_all([])
  end


  def local_radius_value() do
    JetzyModule.SearchConfigurationModule.is_local_radius()
  end

  #----------------------------------------------------------------------------
  # check_is_deleted/1
  #----------------------------------------------------------------------------
  def check_is_deleted(%{is_deleted: false} = user), do: {:ok, user}
  def check_is_deleted(%{is_deleted: nil} = user), do: {:ok, user}
  def check_is_deleted(_user), do: {:error, %{message: "The account is deleted."}}

  #----------------------------------------------------------------------------
  # check_is_deactivated/1
  #----------------------------------------------------------------------------
  def check_is_deactivated(%{is_deactivated: false} = user), do: {:ok, user}
  def check_is_deactivated(%{is_deactivated: nil} = user), do: {:ok, user}
  def check_is_deactivated(_user), do: {:error, %{message: "Your account is deactivated. If you would like to reactivate please email us at contact@jetzyapp.com"}}

  #----------------------------------------------------------------------------
  # check_is_self_deactivated/1
  #----------------------------------------------------------------------------
  def check_is_self_deactivated(%{is_self_deactivated: false} = user), do: {:ok, user}
  def check_is_self_deactivated(%{is_self_deactivated: nil} = user), do: {:ok, user}
  def check_is_self_deactivated(user) do
    case Context.update(User, user, %{is_self_deactivated: true}) do
      {:ok, user} -> {:ok, user}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, %{message: Common.decode_changeset_errors(changeset)}}
      _ -> {:error, %{message: "Something went wrong"}}
        end
  end

  #----------------------------------------------------------------------------
  # add_more_fields/1
  #----------------------------------------------------------------------------
  def add_more_fields(%{id: user_id} = user) do
    points = case Data.Context.Users.point_balance(user.id) do
               %{points: points} -> trunc(points)
               _ -> 0
             end
    user_favourite = %{
      restaurants: Data.Context.UserFavorites.get_by_type(user_id, "restaurant", 1) || [],
      activities: Data.Context.UserFavorites.get_by_type(user_id, "activity", 1) || [],
      cities: Data.Context.UserFavorites.get_by_type(user_id, "city", 1) || []
    }
    user = case Context.get_by(UserSetting, [user_id: user_id]) do
      %UserSetting{is_follow_public: is_follow_public} ->
        if is_follow_public, do: Map.put(user, :is_account_private, false), else: Map.put(user, :is_account_private, true)
      nil ->
        Map.put(user, :is_account_private, true)
    end

    Map.put(user, :user_referral_count, UserReferrals.get_no_of_referrals(user.id))
    |> Map.put(:balance_points, points)
    |> Map.put(:follower_count, UserFollows.get_follower_count(user_id))
    |> Map.put(:followings_count, UserFollows.get_followed_count(user_id))
    |> Map.put(:posts_count, UserShoutouts.get_post_count_by_user_id(user_id))
    |> Map.merge(user_favourite)
    |> Map.put(:user_events, %Scrivener.Page{
      total_entries: 0,
      page_number: 0,
      total_pages: 0,
      entries: []
    })
    |> Map.put(:shareable_link, user.shareable_link)
    |> Context.preload_selective([:interests, :user_images])

  end

  defp welcome_if_is_social(user, %{"login_type" => login_type} = _params) do
    if login_type == "email" do
      send_welcome_email(user)
    else
      {:ok, user}
    end
  end

  defp welcome_if_is_social(user, _params) do
    send_welcome_email(user)
  end

  defp send_welcome_email(user) do
    %{id: user.id, in_the: "welcome_email"}
    |> WelcomeEmailWorker.new(schedule_in: 5)
    |> Oban.insert()
    {:ok, user}
  end

  #----------------------------------------------------------------------------
  # check_active/1
  #----------------------------------------------------------------------------
  def check_active(%User{is_active: true} = user), do: {:ok, user}
  def check_active(%User{is_active: _} = user),
      do: {:ok, %{user: user, message: "User created successfully, Needs Admin approval"}}

  #----------------------------------------------------------------------------
  # check_referral/1
  #----------------------------------------------------------------------------
  def check_referral(%{"referral_code" => referral_code} = params) do
    case Context.get_by(User, referral_code: referral_code) do
      nil ->
        {:error, "incorrect_referral_code"}
      user ->
        referral = UserReferrals.get_by(params["email"], user.id)
        {:ok, referral,
          (referral &&
             Map.merge(
               params,
               %{
                 "is_referral" => true,
                 "is_active" => true,
                 "referred_from_id" => user.id
               }
             )) || params}
    end
  end

  #----------------------------------------------------------------------------
  # check_referral/1
  #----------------------------------------------------------------------------
  def check_referral(%{referral_code: referral_code} = params) do
    case Context.get_by(User, referral_code: referral_code) do
      nil ->
        {:error, "incorrect_referral_code"}

      user ->
        referral = UserReferrals.get_by(params[:email], user.id)

        {:ok, referral,
          (referral &&
             Map.merge(
               params,
               %{
                 is_referral: true,
                 is_active: true,
                 referred_from_id: user.id
               }
             )) || params}
    end
  end
  def check_referral(params), do: {:ok, nil, params}

  #----------------------------------------------------------------------------
  # update_referral/1
  #----------------------------------------------------------------------------
  def update_referral(referral) do
    referral && Users.update(referral, %{"is_accept" => true})
  end

  #----------------------------------------------------------------------------
  # get_follow_status\3
  #----------------------------------------------------------------------------
  def get_follow_status(user, profile_id, current_user_id) do
    Data.Schema.User.get_follow_status(user, profile_id, current_user_id)
  end

  def create_user_interests(user_id, device_id) do
    case GuestInterests.get_guest_interest_by_device_id(device_id) do
      interests when is_list(interests) ->
        interests
        |> Enum.uniq()
        |> Task.async_stream(fn(interest) ->
          try do
            cond do
              existing = Data.Repo.get_by(UserInterest, [user_id: user_id, interest_id: interest]) -> existing
              :else ->
                case Context.create(UserInterest, %{user_id: user_id, interest_id: interest}) do
                  e = {:error, _} ->
                    Logger.warn("#{__MODULE__}:#{__ENV__.line} Insert Error #{inspect e, limit: :infinty, pretty: true}")
                    nil
                  {:ok, v} -> v
                  v -> v
                end
            end
          rescue error ->
            Logger.warn("#{__MODULE__}:#{__ENV__.line} Insert Error #{Exception.format(:error, error, __STACKTRACE__)}")
          catch
            error ->
              Logger.warn("#{__MODULE__}:#{__ENV__.line} Insert Error #{Exception.format(:error, error, __STACKTRACE__)}")
            _, error ->
              Logger.warn("#{__MODULE__}:#{__ENV__.line} Insert Error #{Exception.format(:error, error, __STACKTRACE__)}")
          end
        end)
        |> Enum.map(
             fn
               ({:ok, v}) -> v
               (_) -> nil
             end)
        |> Enum.filter(&(&1))
      _ -> :do_nothing
    end
  end

  def make_shareable_link(user) do
    Task.start(fn ->
      sl = Common.generate_url("user", user.id)
      user
      |> User.changeset(%{shareable_link: sl})
      |> Repo.insert_or_update
    end)
  end

  def verify_referral(params) do
    if params["referral_code"] do
      case UserReferrals.check_record(params["email"], params["referral_code"]) do
        %UserReferral{} = ref
        ->
          Context.update(UserReferral, ref, %{is_accept: true})
          ApiWeb.Utils.Common.update_points(ref.referred_from_id, :sign_up_through_referral)
          Map.put(params, "friend_code", params["referral_code"])
          |> Map.put("is_active", true)
          |> Map.put("is_referral", true)
        nil ->
          case Users.get_referral_code_owner(params["referral_code"]) do
            nil ->
              params
              |> Map.put("is_referral", false)
              |> Map.put("is_active", false)
            %{id: id} ->
              Context.create(UserReferral, %{is_accept: true, referred_to: params["email"],
                referral_code: params["referral_code"], referred_from_id: id})
              ApiWeb.Utils.Common.update_points(id, :sign_up_through_referral)
              params
              |> Map.put("is_referral", true)
              |> Map.put("is_active", true)
          end
      end
    else
      params
      |> Map.put("is_referral", false)
      |> Map.put("is_active", false)
    end
  end

  def make_direct_login_link(user) do
    Task.start(fn ->
      dsl = Common.generate_url("direct-login", user.id)
      user
      |> User.changeset(%{direct_login_link: dsl})
      |> Repo.insert_or_update
    end)
  end

  def handle_sign_in(conn, params) do
    reward_id = "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b35"
    with {:ok, user, token} <- login_either_way(params),
         # {:ok, %User{} = user} <- check_active(user),
         # {:ok, %User{} = user} <- check_email_verified(user),
         {:ok, %User{} = user } <- check_is_deleted(user),
         {:ok, %User{} = user } <- check_is_deactivated(user),
        #  {:ok, %User{} = user} <- check_is_self_deactivated(user),
         {:ok, _data} <-  User.create_user_installs(user, Map.merge(params["installs"], %{"current_jwt" => token}))
      do
      ApiWeb.Utils.Common.update_points(user.id, :sign_in)
      user = add_more_fields(user)
             |>Map.put(:jwt, token)
      conn
      |> render("user_profile.json", %{user: user, current_user_id: user.id})
    else
      {:ok, %{user: _, message: message}} ->
        conn
        |> put_status(401)
        |> render("unauthorized.json", message: message)

      {:error, :unauthorized} ->
        conn |> put_status(401) |> render("unauthorized.json", message: "Invalid Login")

      {:error, message} ->
        conn
        |> put_status(422)
        |> json(%{
          success: false,
          errors: message
        })

      nil ->
        conn
        |> put_status(404)
        |> render("unauthorized.json", message: "User is not Registered at Jetzy")
    end
  end

  #select login way with/without password based on params
  defp login_either_way(params) do
    case params do
      %{"login" => login, "password" => password} ->
        Users.login_by_email_and_pass(login, password)
      # @pri-0 - this is a major security breach - kebrings.
      %{"user_id" => user_id} ->
        Users.login_without_password(user_id)
      error ->
        Logger.warn("[#{__MODULE__}:#{__ENV__.line}] Error (nothing received) #{inspect error, pretty: true}")
        {:error, :unauthorized}
    end
  end

  defp check_referral_code_availability(referral_code, user_id) do
    case UserReferralCodeLogs.get_referral_and_user_id_from_referral_code(referral_code) do
      nil -> :ok
      %{referral_code: ^referral_code, user_id: ^user_id} -> :ok
      _ -> :error
    end
  end

  defp check_profile_image_for_complete_signup(nil, params) do
    {user_image, user_thumb} = Users.upload_profile_image(params) || {nil, nil}
    params
    |> Map.merge(%{"image_name" => user_image, "small_image_name" => user_thumb, "blur_hash" => nil})
  end

  defp check_profile_image_for_complete_signup(_image_name, params) do
    if Map.has_key?(params, "image") do
      {user_image, user_thumb} = Users.upload_profile_image(params) || {nil, nil}
      params
      |> Map.merge(%{"image_name" => user_image, "small_image_name" => user_thumb, "blur_hash" => nil})
      else
      params
    end
  end

  defp get_lat_long(user_id, params) do
    case params do
      %{"latitude" => latitude, "longitude" => longitude} -> %{latitude: latitude, longitude: longitude}
      _ -> Context.get_by(UserGeoLocation, %{user_id: user_id})
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
      NearbyUser:
        swagger_schema do
          title("Nearby User")
          description("Nearby User")
          properties do
            page(:integer, "Page")
            user_latitude(:float, "User Latitude")
            user_longitude(:float, "User Longitude")
            radius(:float, "Radius")
            first_name(:string, "First Name")
            last_name(:string, "Last Name")
            age_from(:integer, "Age From")
            age_to(:integer, "Age To")
            is_traveler(:boolean, "Is Traveler")
            is_local(:boolean, "Is Local")
            gender(:string, "Gender")
            is_friend(:boolean, "Is Friend")
            interest_ids(:map, "List of Interest IDs")
            distance_unit(:string, "km or miles")
          end
          example(%{
            page: 1,
            user_latitude: 33.50,
            user_longitude: 37.50,
            radius: 50.00,
            first_name: "Super",
            last_name: "Admin",
            age_from: 19,
            age_to: 70,
            is_traveler: false,
            is_local: false,
            gender: "",
            is_friend: false,
            distance_unit: "km/miles",
            interest_ids: ["64b04a57-c908-4406-969c-778317d712c8", "8ae4578c-9c32-4a08-aef1-12defc664968"]
          })

        end,
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
      UpdateUserPassword:
        swagger_schema do
          title("Update User Password")
          description("Update User Password")

          properties do
            old_password(:string, "Old Password")
            new_password(:string, "New Password")
          end

          example(%{
            old_password: "123",
            new_password: "12345"
          })
        end,
      User:
        swagger_schema do
          title("User Schema")
          description("User Schema")

          properties do
            id(:integer, "id", required: true)
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
            employer(:string, "Product Manager")
            password(:string, "Password")
            current_country(:string, "Current Country")
            dob(:date, "Date Of Birth")
            is_referral(:boolean, "Is Referred")
            dob_full(:string, "Full Date OF Birth")
            is_active(:boolean, "Is Account active or not")
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
            id: "1",
            name: "Super Admin",
            email: "superadmin@jetzy.com",
            gender: "male",
            scholl: "Brown University",
            current_city: "USA",
            current_country: "phila",
            employer: "Product Manager",
            friends_count: "0",
            followings_count: "0",
            latestInterests: ["Pakistani Professionals", "Pakistani Entrepreneurs",
              "My group", "Jetzy team 2021", "Sports"],
            phone_number: "nil",
            roles: ["owner", "admin"],
            userEvents:
              [
              %{
                interestEvents: [
                  %{
                    description: "Event testing",
                    eventEndDate: "2018-08-02",
                    eventEndTime: "13:00:00",
                    eventStartDate: "2018-08-02",
                    eventStartTime: "08:00:00",
                    formatedAddress: "ajsjsjdkds",
                    id: "3075bfea-63cc-11ec-90d6-0242ac120003",
                    image: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                    baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                    interestId: "0f9165b8-9b72-4551-9e52-f69a61bd8e97",
                    interestName: "Movie Buff",
                    latitude: 687.0,
                    longitude: 345.0,
                    roomId: "9577ce5c-63cb-11ec-90d6-0242ac120003",
                    user: %{
                      firstName: "Super",
                      lastName: "Admin",
                      userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                      userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                      baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                    },
                    eventAttendees: [
                      %{
                        firstName: "test",
                        lastName: "user",
                        userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                        userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                        baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                      },
                      %{
                        firstName: "test",
                        lastName: "user",
                        userId: "b711bf85-963f-42ed-9728-c2047d5694fc",
                        userImage: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
                        baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                      }
                    ]
                  }
                ],
                interestId: "0f9165b8-9b72-4551-9e52-f69a61bd8e97",
                interestName: "Movie Buff"
              }
            ],
            restaurants: [
              %{
                address: "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
                description: "This is a first description test",
                id: "a570fbf8-66b0-4624-a4fa-3b5827cbf452",
                image: "user-favorite-802bfb27-39e1-489d-b011-bb710f606d91.jpg",
                baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                name: "bruh",
                user_favorite_type_id: "restaurant",
                userId: "a17bc893-60e4-4102-99d2-ed701c06373e"
              },
              %{
                address: "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
                description: "This is a first description test",
                id: "325c84a1-7b90-49fd-8f30-6f7255c0b5fd",
                image: "user-favorite-29a9ffd4-77db-4e1e-87fc-21856293aab1.jpg",
                baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                name: "bruh1",
                user_favorite_type_id: "restaurant",
                userId: "a17bc893-60e4-4102-99d2-ed701c06373e"
              }
            ],
            activities: [],
            cities: [
              %{
                address: "Suzy Queue, 4455 Landing Lange, APT 4, Louisville, KY 40018-1234",
                description: "This is a first description test",
                id: "eac7424c-b188-4097-89d7-d4fc008a91c3",
                image: "user-favorite-4b5b28da-879b-4198-ace0-13db112555aa.jpg",
                baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/",
                name: "bruh",
                user_favorite_type_id: "city",
                userId: "a17bc893-60e4-4102-99d2-ed701c06373e"
              }
            ],
            is_active: true
          })
        end,
      UpdateStatus:
        swagger_schema do
          title("Update Status Schema")
          description("Admin Update user Statue Schema")

          properties do
            email(:string, "email")
          end

          example(%{email: "superadmin@jetzy.com"})
        end,
      RequestAdmin:
        swagger_schema do
          title("Send Mail to admin")
          description("Send an email to admin if a user's account got deactivated")
          properties do
            user_email(:string, "User's Email ID", required: true)
            description(:string, "Details about account deactivation", required: true)
          end

          example(%{user_email: "test@jetzy.com", description: "The reason why my account got deactivated"})
        end,
      UserEmailInput:
        swagger_schema do
          title("User Email Verification")
          description("User Email Verification")

          properties do
            user_id(:string, "User_ID")
          end

          example(%{user_id: "aef03ca4-31dc-453d-a00c-937c896d53e8"})
        end,
      InviteUser:
        swagger_schema do
          title("Invite Schema")
          description("User Invite Schema")

          properties do
            referred_to(:string, "Referred To")
          end

          example(%{referred_to: "superadmin@jetzy.com"})
        end,
      InviteCode:
        swagger_schema do
          title("Invite Code")
          description("User Invite Code")

          properties do
            referral_code(:string, "Referral Code")
          end

          example(%{referral_code: "c8d9ht"})
        end,
      InviteCodeResponse:
        swagger_schema do
          title("Invite Code Response")
          example(%{success: true, message: "Invite code is verified."})
        end,
      UserEmailResponse:
        swagger_schema do
          title("User Email Verification")
          example(%{
            ResponseData: %{
              message: "Successfully done"}
          } )
        end,
      CompleteSignup:
        swagger_schema do
          title("Complete Signup")
          description("Complete Invited User Signup")

          properties do
            first_name(:string, "first name")
            last_name(:string, "last name")
            image(:string, "base64 image ")
          end

          example(%{
            first_name: "test",
            last_name: "user",
            image: "image/jpeg;base64,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",
          })
        end,
      SyncContacts:
        swagger_schema do
          title("User Update")
          description("User Update")

          properties do
            emails(:array, "Email list of User's Contacts")
          end
          example(%{
            emails: ["superadmin@jetzy.com", "superadmin23@jetzy.com", "superadmin@jetzy.com"]
          })
        end,
      SyncContactsResponse:
        swagger_schema do
          title("Contact Sync")
          description("Contact Sync")

          example(%{
            responseData: %{
              nonExistingContacts: [
                %{
                  userId: "null",
                  lastName: "null",
                  imageName: "null",
                  firstName: "null",
                  email: "superadmin23@jetzy.com",
                  baseUrl: "null"
                },
                %{
                  userId: "null",
                  lastName: "null",
                  imageName: "null",
                  firstName: "null",
                  email: "superadmin@jetzy.com",
                  baseUrl: "null"
                }
              ],
              existingContacts: [
                %{
                  userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                  lastName: "Admin",
                  imageName: "null",
                  firstName: "Super",
                  email: "superadmin@jetzy.com",
                  baseUrl: "null"
                }
              ]
            }
          }
          )
        end,
      UserImage:
        swagger_schema do
          title("Add User Profile Image")
          description("User Profile image uploading")

          properties do
            image(:string, "image")
          end

          example(%{
            image: ""
          })
        end,
      UserDelete:
        swagger_schema do
          title("Delete Current User Profile")
          description("Delete User Profile")
          example(%{
            message: "User Deleted Successfully"
          })
        end,
      UserImageResponse:
        swagger_schema do
          title("Add User Profile Image")
          description("User Profile image uploading")

          properties do
            image(:string, "image")
          end

          example(%{
            image: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
            baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
          })
        end,
      VerifyUserImage:
        swagger_schema do
          title("Verify User Image")
          description("uploading user image for verification")

          properties do
            image(:string, "image")
          end

          example(%{
            image: ""
          })
        end,
      VerifyUserImageResponse:
        swagger_schema do
          title("Verify User Image")
          description("uploading user image for verification")

          properties do
            image(:string, "image")
          end

          example(%{
            image: "user-0f58276d-05d4-4311-9af0-253e8aaaafe4.jpg",
            baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
          })
        end,
      SignIn:
        swagger_schema do
          title("Sign in User Schema")
          description("User Sign In Schema")

          properties do
            login(:string, "email", required: true)
            password(:string, "password", required: true)
          end

          example(%{
            login: "superadmin@jetzy.com",
            password: "12345",
            installs: %{device_token: "dsadsadsadsa", fcm_token: "dfsfads543fdsfdasd"}
          })
        end,
      DirectSignIn:
        swagger_schema do
          title("Direct Sign in User Schema")
          description("User Sign In Schema without password")

          properties do
            user_id(:string, "User Id", required: true)
          end

          example(%{
            user_id: "a711bf85-963f-42ed-9728-c2047d5694fb",
            installs: %{device_token: "dyugyttycvvsadsa", fcm_token: "dfsfads54sfdasd"}
          })
        end,
      ForgetPassword:
        swagger_schema do
          title("Forget Password User Schema")
          description("User Forget Password Schema")

          properties do
            email(:string, "email", required: true)
            otp_code(:integer, "OTP")
            password(:string, "New Password")
          end

          example(%{
            email: "superadmin@jetzy.com",
            password: "",
            otp_code: ""
          })
        end,
      SignUp:
        swagger_schema do
          title("Sign in User Schema")
          description("User Sign In Schema")

          properties do
            first_name(:string, "first name")
            last_name(:string, "last name")
            email(:string, "email")
            password(:string, "password")
            is_referral(:boolean, "if valid referral code")
            referral_code(:string, "validated referral code")
            image(:string, "base64 image")

            login_type(
              :string,
              "type of account, use one of the following: email, facebook, apple, google"
            )

            social_id(:string, "social id if user signs up by social account")
          end

          example(%{
            first_name: "test",
            last_name: "name",
            email: "superadmin@jetzy.com",
            password: "12345",
            referral_code: "QPJmbpvw",
            login_type: "email",
            social_id: "",
            installs: %{
              device_token: "abc",
              fcm_token: "dsadascsfafawdsad"
            },
            image: "image/jpeg;base64,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",
          })
        end,
      UpdateUserProfile:
        swagger_schema do
          title("User Update")
          description("User Update")

          properties do
            image_name(:string, "Image Name")
            current_city(:string, "Current City")
            first_name(:string, "First Name")
            last_name(:string, "Last Name")
            gender(:string, "Gender")
            home_town_city(:string, "Home Town City")
            longitude(:float, "Long")
            school(:string, "School")
            current_country(:string, "Current Country")
            dob(:date, "Date Of Birth")
            dob_full(:string, "Full Date OF Birth")
            is_email_verified(:boolean, "Email Verified")
            latitude(:float, "Lat")
            panic_message(:string, "Panic Message")
            user_about(:string, "User About")
            home_town_country(:string, "Home Town Country")
            employer(:string, "User Employment")
          end

          example(%{
            current_city: "Phila",
            last_name: "Admin",
            gender: "male",
            login_type: "",
            first_name: "Super",
            home_town_city: "Nevada",
            longitude: "92.98385212321",
            school: "Brown University",
            current_country: "USA",
            dob_full: "String.t | nil",
            latitude: "33.5",
            panic_message: "Cause. A system panics and crashes when a program exercises an operating system bug.",
            user_about: "Interested in food and pop culture. Love hanging out in bars and cafes!",
            home_town_country: "Newzeland",
            employer: "Product Manager"
          })
        end,
      UserReferred:
        swagger_schema do
          title("User Referred")
          description("User Referred")

          example(%{
            ResponseData: %{
              pagination: %{
                totalRows: 12,
                totalPages: 2,
                page: 1
              } ,
              data: [
                %{
                  userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                  lastName: "Admin",
                  imageName: "null",
                  firstName: "Super",
                  email: "superadmin@jetzy.com",
                  baseUrl: "null"
                },
                %{
                  userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                  lastName: "Admin",
                  imageName: "null",
                  firstName: "Super",
                  email: "superadmin@jetzy.com",
                  baseUrl: "null"
                }
              ]
            }
          })

        end,
      NearbyUserList:
        swagger_schema do
          title("Nearby User Response")
          example(%{
            ResponseData: %{
              pagination: %{
                totalRows: 3,
                totalPages: 1,
                page: 1
              },
              data: [
                %{
                  userImage: "user/5661969b-07c9-4676-8541-9b56e8c67228.jpg",
                  userId: "1354bdb1-194f-483c-b04c-a83a2f52267f",
                  lastName: "Ahmed",
                  isActive: false,
                  interests: [],
                  imageThumbnail: "null",
                  firstName: "Saleem",
                  distanceUnit: "miles",
                  distance: 8.474207687433188,
                  baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                },
                %{
                  userImage: "user/1c83f8e2-45ee-43f4-a332-0798d866ec82.jpg",
                  userId: "139186e3-6fdf-471e-99fb-58f9f2c3ab55",
                  lastName: "Ahmed",
                  isActive: false,
                  interests: [
                    %{
                      smallImageName: "68FDC312-9226-4B5B-9ADB-E3013C63E19A--635868615650470000--0009E9CB-D005-4C52-AE3F-D7F6ED16A7AC.png",
                      interestName: "Food & Drink",
                      interestId: "0e8283b9-a1cd-4bcb-b799-810a9137d985",
                      imageName: "Foodie.png",
                      baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                    },
                    %{
                      smallImageName: "D803B6C8-55F5-4ED6-A112-7D8904694186--635868617060430000--19DD1977-93E0-49D5-BE3C-B32014D15B1C.png",
                      interestName: "Clubber",
                      interestId: "1f73cf94-6c64-410b-9428-0e7c75007f33",
                      imageName: "Clubber.png",
                      baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                    },
                    %{
                      smallImageName: "",
                      interestName: "JETZY TEAM",
                      interestId: "f86010d8-ced9-436d-bb7b-b07cef3eb05d",
                      imageName: "0dc0f737-8bc6-49f3-bca0-f9efe9c3ef2e--635751653514969812--c1e28150-d2b6-45de-bde6-b01136081b14.png",
                      baseUrl: "null"
                    },
                    %{
                      smallImageName: "4228C120-157D-49BC-B54D-0C3E786DFCD1--635868646423870000--987842A1-DD8F-4EC2-8257-3D7AF03CCDEC.png",
                      interestName: "Culture",
                      interestId: "fb1348ba-3388-477c-b422-35524a93ee8e",
                      imageName: "CultureLover.png",
                      baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                    }
                  ],
                  imageThumbnail: "null",
                  firstName: "Saleem",
                  distanceUnit: "miles",
                  distance: 8.474207687433188,
                  baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                },
                %{
                  userImage: "user/4df698ea-9985-4870-bbf9-c9c2826ecac4.jpg",
                  userId: "e4615179-f499-4db8-987d-61f3c364957f",
                  lastName: "Ahmed",
                  isActive: false,
                  interests: [],
                  imageThumbnail: "null",
                  firstName: "Saleem",
                  distanceUnit: "miles",
                  distance: 8.474207687433188,
                  baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
                }
              ]
            }

          })
        end,
      SortProfileImages:
        swagger_schema do
          title("Sort Profile Images")
          description("Sort Profile Images")

          properties do
            image_ids(:map, "List of Image IDs")
          end

          example(%{
            image_ids: [
              "64b04a57-c908-4406-969c-778317d712c8",
              "8ae4578c-9c32-4a08-aef1-12defc664968"
            ]
          })
        end,
      VerificationRequest:
        swagger_schema do
          title("User Verification Request")
          description("...")
          properties do
            id(:string, "record id")
            user_id(:string, "user")
            approval_status(:string, "approved|pending|paused|denied|review")
            social_links(:string, "...")
            email(:string, "...")
            mobile(:string, "...")
            contact_preference(:string, "in_app|mobile|email")
            contact_note(:string, "additional contact requests")
            blurb(:string, "Why you should verify me")
            first_name(:string, "...")
            last_name(:string, "...")
            middle_names(:string, "...")
            more_details(:string, "...")
            internal_staff_note(:string, "...")
            staff_note(:strong, "...")
            inserted_on(:date, "Created On Date")
            update_on(:date, "Updated On Date")
            deleted_on(:date, "Deleted On Date")
          end
          example(%{})
        end,
      UpdateLocation:
        swagger_schema do
          title("Change users's location")
          description("Change users's location")

          properties do
            latitude(:float, "User latitude")
            longitude(:float, "User longitude")
            geo_location(:string, "Geo Location")
            location(:string, "Location")
            city_lat_long(:binary, "City lat_long id")
          end

          example(%{
            latitude: 3.12156454,
            longitude: 5.2145987
          })
        end,
      UpdatedLocation:
        swagger_schema do
          title("User location updated")
          description("User location updated")

          example(%{
            message: "User location updated successfully"
          })
        end
    }
  end
end
