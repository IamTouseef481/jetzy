defmodule ApiWeb.Api.Admin.V1_0.AdminView do
  @moduledoc false
  use ApiWeb, :view

  alias ApiWeb.Api.Admin.V1_0.AdminView, as: View
  alias Data.Context.{UserReferrals, UserInstalls}
  alias  ApiWeb.Api.V1_0.UserFavoriteView

  def render("interest.json", %{interest: interest}) do
    Map.from_struct(interest) |> Map.drop([:__meta__, :interest_topics, :user_interest_meta])
  end

  def render("interest.json", %{error: error}) do
    %{errors: error}
  end

  def render("users.json", %{users: users}) do
    page_data = %{
      total_rows: users.total_entries,
      page: users.page_number,
      total_pages: users.total_pages,
      page_size: users.page_size
    }
    %{
      pagination: page_data,
      data: %{users: render_many(users, View, "user.json", as: :user)}
    }
  end

  def render("user.json", %{user: user}) do
    user_installs = UserInstalls.get_device_type_and_last_login__cached(user.id)
    is_referral = user.email && UserReferrals.check_is_refferal_by_email__cached(user.email)


    select_funnel = (Map.get(user, :jetzy_select_status) || :denied) != :denied && :standard || :disabled # longer term temp.
    active_subscription = Jetzy.User.Subscription.Repo.active_by_user(user.id, Noizu.ElixirCore.CallingContext.system())
    active_subscription = cond do
                            length(active_subscription) > 0 -> :approved
                            :else -> :denied
                          end
    
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      image_name: user.image_name,
      image_thumbnail: user.small_image_name,
      current_city: user.current_city,
      gender: user.gender,
      longitude: user.longitude,
      latitude: user.latitude,
      current_country: user.current_country,
      dob: user.dob_full,
      is_active: user.is_active,
      home_town_city: user.home_town_city,
      last_login: user_installs && user_installs.last_login,
      device_type: user_installs && user_installs.device_type,
      app_version: nil,
      login_type: user.login_type,
      is_referral: is_referral && is_referral.is_accept || false,
      is_deleted: user.is_deleted,
      is_deactivated: user.is_deactivated,
      jetzy_exclusive_status: user.jetzy_exclusive_status,
      jetzy_select_status: false, # Hard code to work around issue in build.
      jetzy_select_status_enum: Map.get(user, :jetzy_select_status),
      jetzy_select_funnel: select_funnel,
      jetzy_select_subscription:  active_subscription,
      user_verification_image: user.user_verification_image,
      inserted_at: user.inserted_at,
      effective_status: user.effective_status,
      influencer_level: user.influencer_level,
      user_level: user.user_level,
      follow_status: Map.get(user, :follow_status)
    }
  end

  def render("error.json", %{error: error}) do
    %{error: error}
  end

  def render("message.json", %{message: message}) do
    %{message: message}
  end

  def render("user_detail.json", %{user: user} = data) do
    ApiWeb.Api.V1_0.UserView.render("user_profile.json",
    %{user: user, current_user_id: data.conn.assigns.current_user.id})
  end

  def render("statuses.json", %{statuses: statuses}) do
    Enum.map(statuses, fn status ->
      render("status.json", %{status: status})
    end)
  end

  def render("status.json", %{status: status}) do
    %{
      id: status.id,
      status: status.status
    }
  end

  def render("influencer_messages.json", %{influencer_messages: messages}) do
    page_data = %{
      total_rows: messages.total_entries,
      page: messages.page_number,
      total_pages: messages.total_pages,
      page_size: messages.page_size
    }
    %{
      pagination: page_data,
      data: %{messages: Enum.map(messages, fn message -> View.render("message.json", %{influencer_message: message}) end)}
    }
  end

  def render("message.json", %{influencer_message: message}) do
    %{
    message: message.message,
    type: message.type,
    id: message.id
    }
  end

  def render("follow_statuses.json", %{follow_statuses: follow_statuses}) do
    follow_statuses
  end
end
