defmodule ApiWeb.Api.Admin.V1_0.AdminRewardView do
  @moduledoc false
  use ApiWeb, :view

  def render("rewards.json", %{rewards: rewards}) do
    page_data = %{
      total_rows: rewards.total_entries,
      page: rewards.page_number,
      total_pages: rewards.total_pages,
      page_size: rewards.page_size
    }
    %{
      pagination: page_data,
      data: %{users: render_many(rewards, ApiWeb.Api.Admin.V1_0.AdminRewardView, "reward.json", as: :reward)}
    }
  end

  def render("reward.json", %{reward: reward}) do
    %{
      id: reward.id,
      winning_point: reward.winning_point,
      activity: reward.activity,
      activity_type: reward.activity_type
    }
  end

  def render("reward.json", %{error: error}) do
    %{
      error: error
    }
  end

end