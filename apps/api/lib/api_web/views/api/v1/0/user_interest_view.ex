defmodule ApiWeb.Api.V1_0.UserInterestView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.UserInterestView

  def render("interests.json", %{interests: interests}) do
    %{interests: render_many(interests, UserInterestView, "interest.json")}
  end

  def render("interests_users.json", %{users: users}) do
    render_many(users, UserInterestView, "interests_user")
  end

  def render("interests_user.json", %{user: user}) do
    %{
      user_id: user.id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      user_image: user.image_name,
      image_thumbnail: user.small_image_name
    }
  end

  def render("interest.json", %{interest: interest}) do
    Map.from_struct(interest)
    |> Map.drop([:__meta__, :user, :user_interest, :interest_topics, :user_interest_meta, :user_events, :created_by])
end

  def render("interest.json", %{error: error}) do
    %{errors: error}
  end

end
