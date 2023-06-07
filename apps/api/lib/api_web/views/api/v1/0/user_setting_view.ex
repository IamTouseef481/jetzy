defmodule ApiWeb.Api.V1_0.UserSettingView do
  @moduledoc false
  use ApiWeb, :view

  def render("user_settings.json", %{user_settings: user_settings}) do
    %{
      user: user_settings && ApiWeb.Api.V1_0.UserView.render("user.json", %{user: user_settings.user}),
      is_follow_public: user_settings && user_settings.is_follow_public,
      is_show_followings: user_settings && user_settings.is_show_followings,
    }
  end

  def render("user_settings.json", %{error: error}) do
    %{error: error}
  end

end