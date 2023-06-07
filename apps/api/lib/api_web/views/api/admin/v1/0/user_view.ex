defmodule ApiWeb.Api.Admin.V1_0.UserView do
  @moduledoc false
  use ApiWeb, :view

  alias ApiWeb.Api.Admin.V1_0.AdminView, as: View
  alias Data.Context.{UserReferrals, UserInstalls}
  alias  ApiWeb.Api.V1_0.UserFavoriteView

  def render(template, args) do
    ApiWeb.Api.V1_0.UserView.render(template, args)
  end
  
end
