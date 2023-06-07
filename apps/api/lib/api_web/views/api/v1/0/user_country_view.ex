defmodule ApiWeb.Api.V1_0.UserCountryView do

  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.UserCountryView

  def render("user_countries.json", %{user_countries: user_countries}) do
    render_many(user_countries, UserCountryView, "user_country.json")
  end

  def render("user_country.json", %{user_country: user_country}) do
     %{
      city: user_country.city,
      country: user_country.country,
      displayFromDate: user_country.from_date,
      displayToDate: user_country.to_date,
      fromDate: user_country.from_date,
      toDate: user_country.to_date,
      userCountryId: user_country.id

      }
  end

  def render("user_country.json", %{error: error}) do
    %{errors: error}
  end

end
