defmodule ApiWeb.Api.V1_0.UserFilterView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.UserFilterView

  def render("user_filters.json", %{user_filters: user_filters}) do
    %{user_filters: render_many(user_filters, UserFilterView, "user_filter.json")}
  end

  def render("user_filter.json", %{user_filter: user_filter}) do
    Map.from_struct(user_filter) |> Map.drop([:__meta__])
  end

  def render("user_filter.json", %{error: error}) do
    %{errors: error}
  end
end
