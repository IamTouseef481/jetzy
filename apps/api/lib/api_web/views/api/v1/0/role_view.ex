defmodule ApiWeb.Api.V1_0.RoleView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.RoleView

  def render("roles.json", %{roles: roles}),
      do: roles |> render_many(RoleView, "role.json") |> pagination_resp(roles)

  def render("role.json", %{role: entries}), do: struct_into_map(entries)

  def render("update_role.json", %{role: entries}) do
   %{
      id: entries.id,
      name: entries.name,
      permissions: render_many(entries.permission.permissions, RoleView, "permissions.json")

    }
  end

  def render("permissions.json", %{role: {:ok, permission}}) do
    render("permission.json", %{permission: permission})
  end

  def render("permission.json", %{permission: permission}) do
    %{
      role_id: permission.role.id,
      permission: permission.permission,
      resource_id: permission.resource.id
    }
  end

  def render("role.json", %{error: error}), do:  %{errors: error}
end
