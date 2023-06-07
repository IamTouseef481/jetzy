defmodule ApiWeb.Api.V1_0.UserBlockView do
  @moduledoc false
  use ApiWeb, :view
  # alias ApiWeb.Api.V1_0.UserBlockView

  def render("user_blocks.json", %{user_blocks: user_blocks}) do
    data = render_many(user_blocks.entries, ApiWeb.Api.V1_0.UserView, "user.json", as: :user)
    page_data = %{
      total_rows: user_blocks.total_entries,
      page: user_blocks.page_number,
      total_pages: user_blocks.total_pages
    }
    %{data: data, pagination: page_data}
  end

  def render("user_block.json", %{user_block: %{user_to: user_to} = _user_block}) do
    ApiWeb.Api.V1_0.UserView.render("user.json", %{user: user_to})
  end
  def render("user_block_profiles.json", %{user_blocks: user_blocks}) do
    render_many(user_blocks, ApiWeb.Api.V1_0.UserBlockView , "user_block_profile.json")
  end
  def render("user_block_profile.json", %{user_block: user_block}) do
    %{
      quickBloxId: nil,
      userId: user_block.id
     }
  end

  def render("user_block_profile.json", %{error: error}) do
    %{errors: error}
  end

  def render("user_block.json", %{error: error}) do
    %{errors: error}
  end

  # @todo remove after may 2022
  #  defp mapping_user_fields(user) do
  #    %{
  #      user_id: user.id,
  #      age: 0,
  #      bo_interest_user: [],
  #      email: user.email,
  #      first_name: user.first_name,
  #      gender: user.gender,
  #      image_path: user.image_name,
  #      is_blocked: false,
  #      is_request_sent: false,
  #      last_active_date_time: "/Date(1635344470330+0000)/",
  #      last_name: user.last_name,
  #      quick_blox_id: user.quick_blox_id,
  #      request_sender: "",
  #      social_id: user.social_id,
  #      user_latitude: user.latitude,
  #      user_longitude: user.longitude,
  #      user_small_image_path: "",
  #      view_by: 1
  #    }
  #  end
end
