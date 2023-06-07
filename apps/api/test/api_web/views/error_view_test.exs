defmodule ApiWeb.Api.V1_0.ErrorViewTest do
  use ApiWeb.Api.V1_0.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  @tag :acceptance
  test "renders 404.json" do
    assert render(ApiWeb.ErrorView, "404.json", []) == %{errors: %{detail: "Not Found"}}
  end

  @tag :acceptance
  test "renders 500.json" do
    assert render(ApiWeb.ErrorView, "500.json", []) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
