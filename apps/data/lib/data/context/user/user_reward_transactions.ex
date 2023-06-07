defmodule Data.Context.UserRewardTransactions do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserRewardTransaction

  @spec preload_all(UserRewardTransaction.t()) :: UserRewardTransaction.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

  def get_by_user_id(user_id) do
   query = from(ur in UserRewardTransaction,
            where: ur.user_id == ^user_id ,
            order_by: [desc: ur.updated_at],
            limit: 1)
      Repo.one(query)
   end
   
  def get_point_transactions(user_id, page, page_size \\ 10) do
    redemptions = from o in Data.Schema.UserOfferTransaction,
                       left_join: d in Data.Schema.RewardOffer, on: d.id == o.offer_id,
                       where: o.user_id == ^user_id and o.is_canceled == false,
                       select: %{id: o.id, type: "redeem", event_id:  o.offer_id, point: -o.point, details: d.offer_name, remarks: o.remarks, inserted_at: o.inserted_at, cancelled: o.is_canceled}
    query = from p in UserRewardTransaction,
                 left_join: pd in Data.Schema.RewardManager, on: pd.id == p.reward_id,
                 select: %{id: p.id, type: "reward", event_id: p.reward_id, point: p.point, details: pd.activity, remarks: p.remarks, inserted_at: p.inserted_at, cancelled: p.is_canceled},
                 where: p.user_id == ^user_id and p.is_canceled == false,
                 union_all: ^redemptions,
                 order_by: [desc: fragment("inserted_at")]
    # not performant, Create a view to avoid this.
    embed = from s in subquery(query)
    Repo.paginate(embed, page: page, page_size: page_size)
  end
  
   def get_history_for_redeemed_reward(user_id, page, page_size \\ 10) do
    UserRewardTransaction
    |> where([ur], ur.user_id == ^user_id)
    |> order_by([ur], desc: ur.inserted_at)
    |> Repo.paginate(page: page, page_size: page_size)
   end
end
