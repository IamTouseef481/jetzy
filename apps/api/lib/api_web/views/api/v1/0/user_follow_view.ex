defmodule ApiWeb.Api.V1_0.UserFollowView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.UserFollowView
#  alias ApiWeb.Api.V1_0.UserView
  alias Data.Schema.User
  alias Data.Context.UserFollows


  def render("user_follows.json", %{user_follows: user_follows, current_user_id: current_user_id}) do
    data = Enum.map(user_follows.entries, fn entry ->
      Map.merge(entry, %{current_user_id: current_user_id})
      |> render_one(UserFollowView, "user_follow.json")
    end)
    page_data = %{
      total_rows: user_follows.total_entries,
      page: user_follows.page_number,
      total_pages: user_follows.total_pages
    }
    %{data: data, pagination: page_data}
  end

  def render("user_follows.json", %{user_follows: user_follows}) do
    data = render_many(user_follows.entries, UserFollowView, "user_follow.json")
    page_data = %{
      total_rows: user_follows.total_entries,
      page: user_follows.page_number,
      total_pages: user_follows.total_pages
    }
    %{data: data, pagination: page_data}
  end

  def render("user_follow.json", %{user_follow: %{follower: %User{} = follower} = user_follow}) do
    if Map.has_key?(user_follow, :current_user_id), do:
      (ApiWeb.Api.V1_0.UserView.render("user.json", %{user: follower}) |>
         Map.merge(%{follow_status: UserFollows.get_user_follow_status(follower.id, user_follow.current_user_id)})),
      else: ApiWeb.Api.V1_0.UserView.render("user.json", %{user: follower}) |> Map.merge(%{follow_status: nil})
  end

  def render("user_follow.json", %{user_follow: %{followed: %User{} = followed} = user_follow}) do
    if Map.has_key?(user_follow, :current_user_id), do:
      (ApiWeb.Api.V1_0.UserView.render("user.json", %{user: followed}) |>
         Map.merge(%{follow_status: UserFollows.get_user_follow_status(followed.id, user_follow.current_user_id)})),
      else: ApiWeb.Api.V1_0.UserView.render("user.json", %{user: followed}) |> Map.merge(%{follow_status: nil})
  end

  def render("user_follow.json", %{user_follow: _user_follow}) do
    %{errors: "error"}
  end


  def render("user_follow.json", %{message: message}) do
    %{message: message}
  end

  def render("user_follow.json", %{error: error}) do
    %{errors: error}
  end

end
