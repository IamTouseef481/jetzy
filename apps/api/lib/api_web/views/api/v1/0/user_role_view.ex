defmodule ApiWeb.Api.V1_0.UserRoleView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.UserRoleView
  alias ApiWeb.Utils.Common

  def render("user_roles.json", %{user_roles: user_roles}) do
    %{user_roles: render_many(user_roles, UserRoleView, "user_role.json")}
  end

  def render("user_role.json", %{user_role: user_role}) do
    Common.struct_into_map(user_role)
  end

  def render("user_role.json", %{error: error}) do
    %{errors: error}
  end
end
