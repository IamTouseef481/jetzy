defmodule Data.Context.RewardOffers do
  import Ecto.Query, warn: false

  alias Data.Repo
  #  alias Data.Context
  alias Data.Schema.{RewardOffer, UserRewardTransaction}

  @spec preload_all(RewardOffer.t()) :: RewardOffer.t()
  def preload_all(data), do: Repo.preload(data, [:tier, ])

  def paginate_sorted_on_is_pinned(query, page, page_size \\ 10) do
    query
    |> order_by(asc: :order, desc: :is_pinned)
    |> Repo.paginate([page: page, page_size: page_size])
  end

  def paginate_reward_offers_list(page, page_size \\ 20) do
    # todo cache
    RewardOffer
    |> order_by([asc: :order, asc: :updated_at, desc: :is_deleted])
    |> Repo.paginate([page: page, page_size: page_size])
  end

  def is_offer_redeemed?(offer_id, user_id) do
    from(urt in UserRewardTransaction, where: urt.user_id == ^user_id and urt.reward_id == ^offer_id,
      limit: 1) |> Repo.exists?()
  end

end
