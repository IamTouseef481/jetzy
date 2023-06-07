defmodule ApiWeb.Api.V1_0.PermissionView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.PermissionView
  def render("permissions.json", %{data: params}),
    do: render_many(params, PermissionView, "permission.json") |> pagination_resp(params)

  def render("permission.json", %{error: error}), do: %{errors: error}

  def render("permission.json", data), do: data
end
