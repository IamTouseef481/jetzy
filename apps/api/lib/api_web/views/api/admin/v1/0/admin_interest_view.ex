defmodule ApiWeb.Api.V1_0.AdminInterestView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.AdminInterestView
  alias ApiWeb.Utils.Common
  alias Data.Schema.User
  #  alias Data.Context.Interests


  def render("admin_interests.json", %{admin_interest: admin_interest}) do
    interests_data = render_many(admin_interest, AdminInterestView, "interest.json", as: :interests)
    page_data = %{
      total_rows: admin_interest.total_entries,
      page: admin_interest.page_number,
      total_pages: admin_interest.total_pages,
      page_size: admin_interest.page_size
    }
    %{
      data: interests_data, pagination: page_data
    }
  end
  def render("interest.json", %{interests: interests}) do

   %{
    interest_id: interests.id,
    interest_name: interests.interest_name,
    description: interests.description,
    background_colour: interests.background_colour,
    image_name: interests.image_name,
    small_image_name: interests.small_image_name,
    blur_hash: interests.blur_hash,
    popularity_score: interests.popularity_score,
    status: interests.status,
    is_private: interests.is_private
   }
  end

  #-------------------------------------------------------------------



  def render("interest.json", %{error: error}) do
    %{errors: error}
  end

  def render("user_interests.json", %{interest_users: interest_users}) do
    interest_data = render_many(interest_users, ApiWeb.Api.V1_0.UserInterestView, "interests_user.json",
      as: :user)
    page_data = %{
      total_rows: interest_users.total_entries,
      page: interest_users.page_number,
      total_pages: interest_users.total_pages
    }
    %{data: interest_data, pagination: page_data}
  end



  def render("message.json", %{message: message}) do
    %{message: message}
  end


end
