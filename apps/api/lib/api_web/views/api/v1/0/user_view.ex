defmodule ApiWeb.Api.V1_0.UserView do
  @moduledoc false
  import Ecto.Query, warn: false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.{UserView,UserFavoriteView
#                UserFollowView
    }
    alias Data.Repo
    alias Data.Schema.{User, UserInterest, Interest}

    @status :accepted
    def render("users.json", %{users: users}) do
      render_many(users, UserView, "user.json")
    end

  def render("verification_request.json", args) do
    request = args[:request]
    r = %{
      id: request.id,
      user_id: request.user_id,
      approval_status: request.approval_status,
      social_links: request.social_links,
      email: request.email,
      mobile: request.mobile,
      contact_preference: request.contact_preference,
      contact_note: request.contact_note,
      blurb: request.blurb,
      first_name: request.first_name,
      last_name: request.last_name,
      middle_names: request.middle_names,
      more_details: request.mode_details,
      staff_note: request.staff_note,
      inserted_at: request.inserted_at,
      updated_at: request.updated_at,
      deleted_at: request.deleted_at,
    }
    cond do
      args[:admin] -> put_in(r, [:internal_staff_note], request.internal_staff_note)
      :else -> r
    end
  end
  
    
    def render("users_for_chat.json", %{users: users}) do
      Enum.map(users, fn user ->
        render("user.json", %{user: user})
        |> Map.merge(%{is_group_member: user.is_group_member})
      end)
    end
  #   def get_limited_user_interests_list(user_id) do
  #     Interest
  #     |> join(:inner, [i], ui in UserInterest, on: i.id == ui.interest_id)
  #     |> where([_i, ui], ui.user_id == ^user_id and ui.status == @status)
  #     |> select([i], %{
  #       interest_id: i.id,
  #       interest_name: i.interest_name,
  #       small_image_name: i.small_image_name,
  #       image_name: i.image_name
  #     })
  # #    |> limit(^limit)
  #     |> Repo.all()
  #   end

  def render("nearby_users.json", %{users: users}) do
    data = Enum.map(users.entries, fn user ->
      render("nearby_user.json", %{user: user})
    end)
    page_data = %{
      total_rows: users.total_entries,
      page: users.page_number,
      total_pages: users.total_pages
    }
    %{data: data, pagination: page_data}
  end

  def render("nearby_user.json", %{user: user}) do
    %{
    user_id: user.user.id,
    first_name: user.user.first_name,
    last_name: user.user.last_name,
    user_image: user.user.image_name,
    image_thumbnail: user.user.small_image_name,
    distance: user.distance,
    distance_unit: user.distance_unit,
    is_active: user.user.is_active,
    blur_hash: user.user.blur_hash,
    is_local: user.is_local,
    is_traveler: user.is_local && not user.is_local || false,
    is_friend: user.is_friend,
    age: user.user.age,
    interests: Enum.map(user.user.user_interests, fn user_interest ->
      %{
      interest_id: user_interest.interest.id,
      interest_name: user_interest.interest.description,
      image_name: user_interest.interest.image_name,
      small_image_name: user_interest.interest.small_image_name
      }
    end)
    }
  end

  def render("user.json", %{user: user, message: user_creation_message}) do
    {:ok, user_role} = SecureX.UserRoles.get(%{user_id: user.id})

    select_funnel = (Map.get(user, :jetzy_select_status) || :denied) != :denied && :standard || :disabled # longer term temp.
    active_subscription = Jetzy.User.Subscription.Repo.active_by_user(user.id, Noizu.ElixirCore.CallingContext.system())
    active_subscription = cond do
                            length(active_subscription) > 0 -> :approved
                            :else -> :denied
                          end
    %{
      user_id: user.id,
      age: 0,
      bo_interest_user: [],
      email: user.email,
      first_name: user.first_name,
      gender: user.gender,
      image_path: user.image_name,
      is_active: user.is_active,
      is_blocked: false,
      is_request_sent: false,
      last_active_date_time: "/Date(1635344470330+0000)/",
      last_name: user.last_name,
      quick_blox_id: user.quick_blox_id,
      request_sender: "",
      social_id: user.social_id,
      user_latitude: user.latitude,
      user_longitude: user.longitude,
      blur_hash: user.blur_hash,
      image_thumbnail: user.small_image_name,
      view_by: 1,
      message: user_creation_message,
      role_id: user_role,
      jetzy_exclusive_status: user.jetzy_exclusive_status,
      jetzy_select_status: false, # Hard code to work around issue in build.
      jetzy_select_funnel: select_funnel,
      jetzy_select_subscription: active_subscription,
    }
  end

  def render("user.json", %{user: user}) do
  
  
    select_funnel = (Map.get(user, :jetzy_select_status) || :denied) != :denied && :standard || :disabled # longer term temp.
    active_subscription = Jetzy.User.Subscription.Repo.active_by_user(user.id, Noizu.ElixirCore.CallingContext.system())
    active_subscription = cond do
                            length(active_subscription) > 0 -> :approved
                            :else -> :denied
                          end
    
    %{
      user_id: user.id,
      first_name: user.first_name,
      user_image: user.image_name,
      last_name: user.last_name,
      is_active: user.is_active,
      image_thumbnail: user.small_image_name,
      blur_hash: Map.get(user, :blur_hash),
      is_local: Map.get(user, :is_local) || false,
      is_traveler: not(Map.get(user, :is_local) || false),
      is_friend: Map.get(user, :is_friend) || false,
      age: Map.get(user, :age),
      chat_settings: Map.get(user, :chat_settings) || %{enabled: true},
      jetzy_exclusive_status: Map.get(user, :jetzy_exclusive_status) || :denied,
      jetzy_select_status: false, # Hard code to work around issue in build.
      jetzy_select_funnel: select_funnel,
      jetzy_select_subscription:  active_subscription,
    }
  end

  def render("user_referred.json", %{user_referred: user_referred}) do
    data = render_many(user_referred.entries, UserView, "user.json", as: :user)
    page_data = %{
      total_rows: user_referred.total_entries,
      page: user_referred.page_number,
      total_pages: user_referred.total_pages
    }
    %{data: data, pagination: page_data}
  end

  def render("show.json", %{user: user}) do
    render_one(user, UserView, "user.json")
  end

  def render("auth_user.json", %{jwt: jwt, user: user}) do
    {:ok, user_role} = SecureX.UserRoles.get(%{user_id: user.id})
    %{
      user_id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      dob: user.dob,
      is_active: user.is_active,
      latitude: user.latitude,
      login_type: user.login_type,
      longitude: user.longitude,
      message: user.panic_message,
      quick_blox_password: user.quick_blox_password,
      quick_blox_id: user.quick_blox_id,
      social_id: user.social_id,
      usersettings: render("user_settings.json", %{jwt: jwt, user: user}),
      role_id: user_role
    }
  end

  def render("user_settings.json", %{jwt: jwt, user: user}) do
    %{
      valid_credentials: true,
      is_active: user.is_active,
      jwt: jwt,
      is_deactivated: user.is_deactivated,
      auth_token: user.id,
      is_new_user: false,
      login_type: user.login_type
    }
  end

  def render("jwt.json", %{jwt: jwt, user: user}) do
    render("auth_user.json", %{jwt: jwt, user: user})
  end

  def render("unauthorized.json", %{message: message}) do
    %{authenticated: false, message: message}
  end
  
  @doc """
    @todo API SHOULD RESTRICT PRIVATE DETAILS IF USER IS PRIVATE AND REQUESTER IS NOT FOLOWWER
  """
  def render("user_profile.json", %{user: user} = data) do
    follow_status = Map.get(user, :follow_status)
    jwt = if Map.has_key?(user, :jwt), do: user.jwt, else: nil
    user_role = case SecureX.UserRoles.get(%{user_id: user.id}) do
      {:ok, user_role} -> user_role
      {:error, error} -> []
    end


    select_funnel = (Map.get(user, :jetzy_select_status) || :denied) != :denied && :standard || :disabled # longer term temp.
    active_subscription = Jetzy.User.Subscription.Repo.active_by_user(user.id, Noizu.ElixirCore.CallingContext.system())
    active_subscription = cond do
                            length(active_subscription) > 0 -> :approved
                            :else -> :denied
                          end
    
    %{
      user_id: user.id,
      school: user.school,
      employer: user.employer,
      email: user.email,
      totalPoint: user.balance_points,
      follower_count: user.follower_count,
      followings_count: user.followings_count,
      follow_status: follow_status,
      posts_count: user.posts_count,
      first_name: user.first_name,
      last_name: user.last_name,
      display_dob: user.dob_full,
      dob: user.dob,
      friend_code: user.friend_code,
      gender: user.gender,
      latitude: user.latitude,
      login_type: user.login_type,
      longitude: user.longitude,
      message: user.panic_message,
      quick_blox_password: user.quick_blox_password,
      quick_blox_id: user.quick_blox_id,
      social_id: user.social_id,
      home_town_city: user.home_town_city,
      home_town_country: user.home_town_country,
      image_path: user.image_name,
      image_thumbnail: user.small_image_name,
      blur_hash: user.blur_hash,
      is_email_verified: user.is_email_verified,
      is_password: (if is_nil(user.password), do: false, else: true),
      is_referral: user.is_referral,
      referral_code: user.referral_code,
      user_about: user.user_about,
      user_referral_count: user.user_referral_count,
      interest_list: render_many(user.interests, ApiWeb.Api.V1_0.UserInterestView, "interest.json", as: :interest),
      latest_interests: data[:current_user_id] == user.id && Data.Context.UserInterests.get_limited_user_interests_list(user.id)
      || Data.Context.UserInterests.get_limited_public_user_interests_list(data[:current_user_id], user.id),
      user_images: render_many(user.user_images, ApiWeb.Api.V1_0.UserImageView, "user_image.json"),
      restaurants: render_one(user.restaurants, UserFavoriteView, "user_favorites.json", as: :user_favorites),
      cities: render_one(user.cities, UserFavoriteView, "user_favorites.json", as: :user_favorites),
      activities: render_one(user.activities, UserFavoriteView, "user_favorites.json", as: :user_favorites),
      current_city: user.current_city,
      current_country: user.current_country,
      is_active: user.is_active,
      shareable_link: user.shareable_link,
      user_verification_image: user.user_verification_image,
      language: user.language,
      usersettings: render("user_settings.json", %{jwt: jwt, user: user}),
      user_events: render_one(user.user_events, ApiWeb.Api.V1_0.UserEventView, "user_interest_events.json", as: :interest_events),
      role_id: user_role,
      is_selfie_verified: user.is_selfie_verified,
      is_account_private: user.is_account_private,
      is_self_deactivated: user.is_self_deactivated,
      effective_status: user.effective_status,
      influencer_level: user.influencer_level,
      user_level: user.user_level,
      chat_settings: user.chat_settings,
      jetzy_exclusive_status: user.jetzy_exclusive_status,
      jetzy_select_status: false, # Hard code to work around issue in build.
      jetzy_select_funnel: select_funnel,
      jetzy_select_subscription: active_subscription,
    } |> IO.inspect([pretty: true, limit: :infinity])
  end


  def render("user_profile_update.json", %{user: user}) do
    post_types = Data.Context.ShoutoutTypes.get_by_user_id(user.id)
    blocked_users = Data.Context.UserBlocks.get_by_user(user.id, 1)
    blocked_by_users = Data.Context.UserBlocks.get_from_user(user.id)
    jwt = if Map.has_key?(user, :jwt), do: user.jwt, else: nil

    %{
      blocked_by_users: render_many(blocked_by_users, ApiWeb.Api.V1_0.UserBlockView , "user_block_profile.json", as: :user_block),
      blocked_user: render_many(blocked_users, ApiWeb.Api.V1_0.UserBlockView , "user_block_profile.json", as: :user_block),
      bo_interest_user: render_many(user.interests, ApiWeb.Api.V1_0.UserInterestView, "interest.json", as: :interest),
      bo_public_interest: [],
      bo_shoutout_type: render_many(post_types, ApiWeb.Api.V1_0.PostTypeView, "post_type.json"),
      bo_user_preference: %{
        friends: "",
        interests: "",
        preference_types: Data.Context.UserPreferences.get_by_user_id(user.id)
      },
      bo_friend: [],
      user_private_interests: [],
      display_dob: user.dob_full,
      dob: user.dob,
      is_selfie_verified: user.is_selfie_verified,
      user_verification_image: user.user_verification_image,
      user_id: user.id,
      school: user.school,
      email: user.email,
      employer: user.employer,
      follower_count: user.follower_count,
      followings_count: user.followings_count,
      posts_count: user.posts_count,
      last_name: user.last_name,
      is_email_verified: user.is_email_verified,
      is_password: (if is_nil(user.password), do: false, else: true),
      is_referral: user.is_referral,
      referral_code: user.referral_code,
      user_about: user.user_about,
      user_referral_count: user.user_referral_count,
      latest_interests: Data.Context.UserInterests.get_limited_user_interests_list(user.id),
      totalPoint: user.balance_points,
      restaurants: user.restaurants,
      cities: user.cities,
      activities: user.activities,
      is_active: user.is_active,
      latitude: user.latitude,
      login_type: user.login_type,
      longitude: user.longitude,
      message: user.panic_message,
      quick_blox_password: user.quick_blox_password,
      quick_blox_id: user.quick_blox_id,
      social_id: user.social_id,
      first_name: user.first_name,
      friend_code: user.friend_code,
      gender: user.gender,
      home_town_city: user.home_town_city,
      home_town_country: user.home_town_country,
      image_path: user.image_name,
      image_thumbnail: user.small_image_name,
      interest_list:
        Enum.map_join(user.interests, ",", fn m ->
          Map.from_struct(m) |> get_in([:interest_name])
        end),
      user_images: render_many(user.user_images, ApiWeb.Api.V1_0.UserImageView, "user_image.json"),
      usersettings: render("user_settings.json", %{jwt: jwt, user: user})
    }
  end


  def render("user_profile.json", %{error: error}) do
    %{errors: error}
  end

  def render("forget.json", %{message: message}) do
    %{message: message}
  end

  def render("delete.json", %{message: message}) do
    %{message: message}
  end

  def render("error.json", %{error: message}) do
    %{errors: %{message: message, status: 400}}
  end

  def render("error.json", %{message: message}) do
    %{errors: message}
  end

  def render("message.json", %{message: message}) do
    %{message: message}
  end

  def render("user_profile_update.json", %{error: error}) do
    %{errors: error}
  end

  def render("sync_contacts.json", %{existing_emails: existing_emails, non_existing_emails: non_existing_emails}) do
    %{
      existing_contacts: existing_emails,
      non_existing_contacts: non_existing_emails
    }
  end


def render("verify_profile_image.json", %{similarity: similarity, result: result}) do
  %{
    similarity: similarity,
    result: result
  }
end

def render("verify_profile_image.json", %{error: error}) do
  %{errors: error}
end

end
