defmodule ApiWeb.Api.V1_0.GuestInterestView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.GuestInterestView
#  alias ApiWeb.Utils.Common

  def render("save_guest_interest.json", %{guest_interest: guest_interest}) do
    guest_interest
  end

  def render("guest_interests.json", %{guest_interests: guest_interests}) do
    render_many(guest_interests, GuestInterestView, "guest_interest.json")
  end

  def render("guest_interest.json", %{guest_interest: guest_interest}) do
    guest_interest
  end

  def render("guest_interest.json", %{message: message}) do
    message
  end

  def render("guest_interest.json", %{error: error}) do
    %{errors: error}
  end
end
