defmodule ApiWeb.Api.V1_0.PostTypeView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.PostTypeView

  def render("post_types.json", %{post_types: post_types}) do
    render_many(post_types, PostTypeView, "post_type.json")
  end

  def render("post_type.json", %{post_type: post_type}) do
    Map.from_struct(post_type) |> Map.drop([:__meta__])
  end

  def render("post_type.json", %{error: error}) do
    %{errors: error}
  end
end
