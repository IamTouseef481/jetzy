defmodule Data.Context.RewardManagers do
  import Ecto.Query, warn: false

  alias Data.Repo
  alias Data.Context
  alias Data.Context.{UserRewardTransactions, RewardManagers}
  alias Data.Schema.{UserRewardTransaction, Permission, Resource, RewardManager}
  
  @spec preload_all(RewardManager.t()) :: RewardManager.t()
  def preload_all(data), do: Repo.preload(data, [])

  def paginate_rewards(page, page_size \\ 10) do
    RewardManager
    |> order_by([rm], rm.activity_type)
    |> Repo.paginate(%{page: page, page_size: page_size})
  end

  def get_reward_offer_by_activity_type(activity_type) do
    RewardManager
    |> where([rm], rm.activity_type == ^activity_type)
    |> order_by([rm], [desc: rm.inserted_at])
    |> limit(1)
    |> Repo.one()
  end
  
  @doc """
  @deprecated typo in name.
  """
  def get_reward_offer_by_acitivity_type(activity_type), do: get_reward_offer_by_activity_type(activity_type)

  def get_max_activivty_type() do
    RewardManager
    |> select([rm], max(rm.activity_type))
    |> Repo.one()
  end


  def update_points(user_id, reward_id, points, remarks \\ nil, is_completed \\ true) do
    previous_points = case Data.Context.Users.point_balance(user_id) do
                        %{points: v} -> trunc(v)
                        _ -> 0
                      end
    new_balance_point = previous_points + points
    Context.create(UserRewardTransaction, %{
      user_id: user_id,
      reward_id: reward_id,
      point: points,
      balance_point: new_balance_point,
      remarks: remarks,
      is_completed: is_completed
    })
  end
  
  def update_points(user_id, activity_type) do
    case RewardManagers.get_reward_offer_by_activity_type(activity_type) do
      nil -> :do_nothing
      %RewardManager{id: reward_id, winning_point: points, activity: remarks} ->
        previous_points = case Data.Context.Users.point_balance(user_id) do
                            %{points: points} -> trunc(points)
                            _ -> 0
                          end
        new_balance_point = previous_points + points
        Context.create(UserRewardTransaction, %{
          user_id: user_id,
          reward_id: reward_id,
          point: points,
          balance_point: new_balance_point,
          remarks: remarks,
          is_completed: true
        })
    end
  end
  
end
