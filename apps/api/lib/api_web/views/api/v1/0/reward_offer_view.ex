defmodule ApiWeb.Api.V1_0.RewardOfferView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.RewardOfferView
  alias Data.Context.RewardOffers

  def render("rewards_offers.json", %{rewards_offers: offers}) do
    current_user_id = offers.current_user_id
    data = Enum.map(offers.entries, fn offer ->
      render_one(Map.merge(offer, %{current_user_id: current_user_id}), RewardOfferView, "reward_offer.json")
    end)
    page_data = %{
      total_rows: offers.total_entries,
      page: offers.page_number,
      total_pages: offers.total_pages
    }
    %{
      pagination: page_data,
      data: data
    }
  end

  def render("reward_offer.json", %{reward_offer: reward_offer}) do
    current_user_id = reward_offer.current_user_id
    status = %{
      status_id: reward_offer.status && reward_offer.status.id,
      status: reward_offer.status && reward_offer.status.status
    }
    %{
      is_redeemed: RewardOffers.is_offer_redeemed?(reward_offer.id, current_user_id),
      image_path: reward_offer.image_name,
      offer_description: reward_offer.offer_description,
      offer_name: reward_offer.offer_name,
      point_required: reward_offer.point_required,
      reward_offer_id: reward_offer.id,
      latitude: reward_offer.latitude,
      longitude: reward_offer.longitude,
      is_pinned: reward_offer.is_pinned,
      event_start_date: reward_offer.event_start_date,
      event_end_date: reward_offer.event_end_date,
      multi_redeem_allowed: reward_offer.multi_redeem_allowed,
      price_of_ticket: reward_offer.price_of_ticket,
      link: reward_offer.link,
      location: reward_offer.location,
      tier: reward_offer.tier && %{
        tier_name: reward_offer.tier.tier_name,
        description: reward_offer.tier.description,
        tier_id: reward_offer.tier.id
      } || nil,
      status: status,
      reward_images: Enum.map(reward_offer.reward_images, fn image ->
        %{image_name: image.image_name,
          image_thumbnail: image.small_image_name,
          id: image.id}
      end)
    }
  end


  def render("point_txn_history.json", %{transactions: transactions}) do
    data = render_many(transactions, RewardOfferView, "point_txn.json", as: :transaction)
    page_data = %{
      total_rows: transactions.total_entries,
      page: transactions.page_number,
      total_pages: transactions.total_pages
    }
    %{
      pagination: page_data,
      data: data
    }
  end
  
  def render("point_txn.json", %{transaction: transaction}) do
    remarks = cond do
                transaction.remarks == nil || transaction.remarks == "" ->
                  cond do
                    transaction.details == nil || transaction.details == "" -> transaction.type
                    :else -> transaction.details
                  end
                :else -> transaction.remarks
              end
    %{
      id: transaction.id,
      points: transaction.point,
      event_id: transaction.event_id,
      type: transaction.type,
      remarks: remarks,
      inserted_at: transaction.inserted_at
    }
  end
  
  def render("redeemed_reward_history_list.json", %{history_list: history_list}) do
    data = render_many(history_list, RewardOfferView, "redeemed_reward_history.json", as: :history)
    page_data = %{
      total_rows: history_list.total_entries,
      page: history_list.page_number,
      total_pages: history_list.total_pages
    }
    %{
      pagination: page_data,
      data: data
    }
  end

  def render("redeemed_reward_history.json", %{history: history}) do
    %{
      id: history.id,
      points: history.point,
      remarks: history.remarks,
      inserted_at: history.inserted_at
    }
  end

  def render("point_balance.json", %{points: points}) do
    points = case points do
               v when is_integer(v) -> points
               nil -> 0
             end
    %{totalPoint: points}
  end
  
  def render("total_points.json", %{points: points}) do
    points =
    case points do
      nil -> 0
      _ -> trunc(points.balance_point)
    end
    %{totalPoint: points}
  end

  def render("reward_transaction.json", %{message: message, status: status}) do
    %{message: message, status: status}
  end

  def render("reward_offer.json", %{message: message}) do
    %{message: message}
  end

  def render("reward_offer.json", %{error: error}) do
    %{errors: error}
  end

  def render("tiers.json", %{tiers: tiers}) do
    Enum.map(tiers, fn tier ->
    render("tier.json", %{tier: tier})
    end)
  end

  def render("tier.json", %{tier: tier}) do
    %{
    id: tier.id,
    tier_name: tier.tier_name,
    description: tier.description,
    start_point: tier.start_point,
    end_point: tier.end_point
    }
  end

end
