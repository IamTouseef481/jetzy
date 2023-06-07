#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.SocialAuthController do
  @moduledoc """
  Manage social authentication/login/linking.
  @todo complex sign-up/register/link logic should be moved out of controller.
  """
  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use ApiWeb, :controller
  use PhoenixSwagger
  require Logger
  alias Data.Schema.{UserSocialAccount, User}
  alias Data.Context.{UserSocialAccounts, Users, GuestInterests}
  alias Jetzy.SocialClients
  alias Data.Context
  alias SecureX.Context, as: SecureXContext
  alias Api.Guardian
  alias ApiWeb.Api.V1_0.UserController

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # social_sign_up/2
  #----------------------------------------------------------------------------
  swagger_path :social_sign_up do
    post "/v1.0/social-sign-up"
    summary "User Social Sign up Google, Facebook, Apple, referral code"
    description "Social Sign up with Google, Facebook, Apple and can also add referral code here"
    produces "application/json"
    parameters do
      body :body, Schema.ref(:SocialSignUp), "Social Sign Up Params", required: true
    end
    response 200, "Ok", Schema.ref(:SocialSignUp)
  end

  @doc """
  Complex social signup logic should be moved into a domain object for testability/reuse.
  """
  def social_sign_up(conn, params) do
    with {:ok, user} <- sign_in_with_social_account(conn, params),
#           this check is commented as some APIs needed jwt authorization after signup like verify identity
#         {:ok, %User{}} <- UserController.check_active(user),
         {:ok, _user_settings} <- User.create_user_settings(user),
         {:ok, _pid} <- ApiWeb.Utils.PushNotification.create_notification_settings(user.id),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user),
         {:ok, _installs} <-  User.create_user_installs(user, Map.merge(params["installs"], %{"current_jwt" => token}))
            do
      %{"installs" => %{"device_token" => device_token}} = params
      UserController.create_user_interests(user.id, device_token)
      Task.start(fn  ->
        GuestInterests.delete_guest_interests_by_device_id(device_token)
      end)
      updated_user = UserController.add_more_fields(user)
                     |>Map.put(:jwt, token)
      conn
      |> put_view(ApiWeb.Api.V1_0.UserView)
      |> render("user_profile.json", %{
        user: updated_user,
        current_user_id: updated_user.id
      })
      #      |> render("jwt.json", jwt: token, user: user)
    else
      {:ok, %{user: user, message: message}} ->
        conn
        |> put_status(200)
        |> put_view(ApiWeb.Api.V1_0.UserView)
        |> render("user.json", user: user, message: message)
      {:error, %Ecto.Changeset{} = error} = res ->
        res
        conn
        |> put_status(422)
        |> json(%{
          success: false,
          errors: ApiWeb.Utils.Common.decode_changeset_errors(error)
        })
      {:error, message} ->
        conn
        |> put_status(422)
        |> json(%{
          success: false,
          errors: message
        })
    end
  end

  #============================================================================
  # Internal Methods
  #============================================================================

  #----------------------------------------------------------------------------
  # sign_in_with_social_account/2
  #----------------------------------------------------------------------------
  @doc """
  Sign user in via federated login.
  """
  def sign_in_with_social_account(conn, %{"token" => token, "provider" => social_network} = params) do
    social_network = String.to_atom(social_network)
    with {:ok, user_data} <- SocialClients.Client.user_info(social_network, token) |> IO.inspect(label: "user_info"),
         user_data <- add_referral_code_to_user_data(params, user_data), # Maybe? this would let a user hack/get a temporary facebook account then get registered as a full user on jetzy.
         {:ok, user} <- get_or_create_social_account(conn, social_network, user_data, params["email"]) do
      {:ok, user}
    else
      user = %{email: nil} ->
        Logger.warn("Social Login| User Can Not Login: Missing Email. #{inspect user, pretty: true}")
        {:error, :email_permission_denied}
      {:error, error} ->
        Logger.warn("Social Login| Error Raised| #{inspect {:error, error}, pretty: true}")
        {:error, error}
      {:error, :credential, error} ->
        Logger.warn("Social Login| Credential Issue| #{inspect {:error, :credential, error}, pretty: true}")
        error
        error ->
          Logger.warn("Social Login| Unmatched Error Response #{inspect error, pretty: true}")
          error
    end
  end

  #----------------------------------------------------------------------------
  # get_or_create_social_account/2
  #----------------------------------------------------------------------------
  @doc """
  Get or create new social account linked login.
  """
  def get_or_create_social_account(conn, social_network, %{id: social_account_id} = params, email) do
    reward_id = "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b37"
    params_for_referral_check = %{"email" => params[:email] || email, "referral_code" => params[:referral_code]}
    case UserSocialAccounts.query_by_social_network_and_id(social_network, social_account_id) do
      %UserSocialAccount{user: user} ->
        with {:ok, %User{} = user } <- UserController.check_is_deleted(user),
             {:ok, %User{} = user } <- UserController.check_is_deactivated(user)
            #  {:ok, %User{} = user } <- UserController.check_is_self_deactivated(user)
            #  params_for_update <- UserController.verify_referral(params_for_referral_check),
            #  {:ok, %User{} = user} <- Users.update_for_social(user, params_for_update |> Map.delete("referral_code"))
             do
              if params[:referral_code] do
                {:error, "You already have an account with Jetzy please log that in."}
              else
                {:ok, user}
              end
        else
          {:error, %{message: message}} -> {:error, message}
          {:error, message} -> {:error, message}
        end
      # User never logged in with this social account.
      nil ->
        #  Check if emails exists.
        # - if not exists then create a user for that email (without password)
        # - if exists, get that user and assign that user id to that already existing user

        with email when is_binary(email) <- params[:email] || email || :email_is_nil,
             nil <- Context.get_by(User, [email: email]),
             params_for_update <- UserController.verify_referral(params_for_referral_check),
             params <- get_params(params, params_for_update),
             {:ok, %User{} = user} <- Users.create(params["email"] && params || Map.put(params, "email", email)),
             _ <- ApiWeb.Utils.Common.update_points(user.id, :sign_up_1000),
             {:ok, %{__struct__: _}} <- SecureXContext.create_user_role(%{"user_id" => user.id, "role_id" => params["role"] || "user"}) do
          UserController.make_shareable_link(user)
          create_social_account(user.id, social_network, social_account_id)
        else
          :email_is_nil ->
            Logger.error("Social Account Login Failed| #{inspect {:email_is_nil}}")
            {:error, ["Email is null"]}
          nil ->
          Logger.error("Social Account Login Failed| #{inspect {:email_is_nil}}")
            {:error, ["Resend Token with email permission"]}
          %User{} = user ->
            create_social_account(user.id, social_network, social_account_id)
          {:ok, %User{} = user} ->
            create_social_account(user.id, social_network, social_account_id)
          reason ->
          Logger.error("Social Account Login Failed| Reason #{inspect reason}")
          reason
        end
    end
  end


  #----------------------------------------------------------------------------
  # add_referral_code_to_user_data/2
  #----------------------------------------------------------------------------
#  @doc """
#  Add referral code to user account data.
#  """
  defp add_referral_code_to_user_data(%{"referral_code" => referral_code}, user_data) do
    Map.merge(user_data, %{referral_code: referral_code})
  end
  defp add_referral_code_to_user_data(_, user_data), do: user_data

  #----------------------------------------------------------------------------
  # get_params\1
  #----------------------------------------------------------------------------
  def get_params(%{name: name, email: email}, params) do
     n =  String.split(name, " ")
     %{"first_name" => List.first(n), "last_name" => List.last(n), "email" => email} |> Map.merge(params)
  end

  def get_params(%{email: email}, params) do
    %{"email" => email} |> Map.merge(params)
  end

  #----------------------------------------------------------------------------
  # create_social_account\3
  #----------------------------------------------------------------------------
#  @doc """
#  Create new social account.
#  """
  defp create_social_account(user_id, social_network, social_account_id) do
    with params <- %{user_id: user_id, type: "#{social_network}", external_id: social_account_id},
         changeset <- UserSocialAccount.changeset(%UserSocialAccount{}, params),
         {:ok, %UserSocialAccount{} = social_account } <- Data.Repo.insert(changeset) do
      # Return the social account after creation
      social_a = social_account |> Context.preload_selective(:user)
      {:ok, social_a.user}
    else
      {:error, _} = error -> error
      error -> {:error, error}
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
      SocialSignUp: swagger_schema do
        title "Social Sign Up User Schema"
        description "Social Sign Up Schema"
        properties do
          token :string, "token"
          provider :string, "provider"
          email :string, "email"
        end
        example %{
          token: "",
          provider: "google",
          installs: %{device_token: "4dsa8s-dsad4-dsadsadasdsa", fcm_token: "dsad-dfsfads543fdsfdasd45"}
        }
      end
    }
  end
end
