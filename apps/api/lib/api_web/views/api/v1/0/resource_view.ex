defmodule ApiWeb.Api.V1_0.ResourceView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.ResourceView

  def render("resources.json", %{resources: params}),
    do: render_many(params, ResourceView, "resource.json") |> pagination_resp(params)

  def render("resource.json", %{resource: resource}), do: struct_into_map(resource)

  def render("resource.json", %{error: error}), do: %{errors: error}
end
