defmodule Data.Helper.UserRewardTransactionHelper do

  alias Data.Repo
  alias Data.Schema.{UserRewardTransaction, RewardManager, User, UserReferral, UserEvent, RoomMessage, Room, UserEventLike}
  alias ApiWeb.Utils.Common
  alias Data.Context
  import Ecto.Query

  def run() do
    run_for_sign_up(get_users_without_sign_up_reward()) |> Stream.run()
    run_for_post_points(get_user_ids_who_upload_posts()) |> Stream.run()
    run_for_user_referrals(get_users_who_reffered_someone()) |> Stream.run()
    run_for_comments(get_user_ids_who_commented()) |> Stream.run()
    run_for_event_likes(get_user_ids_who_liked_posts()) |> Stream.run()
    run_for_starting_group_chats(get_user_ids_who_started_group_chat()) |> Stream.run()
  end

  #========================================================================
  # Functions for updating points for sign up
  #========================================================================

  def run_for_sign_up(user_ids) do
    Task.async_stream(user_ids, fn user_id -> Common.update_points(user_id, :sign_up_1000) end, max_concurrency: 10, timeout: :infinity)
  end

  defp get_users_without_sign_up_reward() do
    User
    |> where([u], u.id not in fragment("select user_id from user_reward_transactions join reward_managers rm on rm.id = user_reward_transactions.reward_id where rm.activity_type = 39"))
    |> select([u], u.id)
    |> Repo.all()
  end

  #========================================================================
  # Functions for updating points for creating posts
  #========================================================================

  def run_for_post_points(user_ids) do
    %RewardManager{id: reward_id, activity: remarks} = Data.Context.get_by(
      RewardManager,
      [activity_type: :create_a_event]
    )
    Task.async_stream(
      user_ids,
      fn user_id ->
        count_of_total_posts = get_count_of_posts(user_id)
        count_of_reward_transactions = get_count_of_reward_transactions(user_id, reward_id)
        diff = count_of_total_posts - count_of_reward_transactions
        diff = if diff <= 0, do: [], else: 1..diff |> Enum.to_list
        Enum.each(
          diff,
          fn _x ->
             Common.update_points(user_id, :create_a_event)
          end
        )
      end,
      max_concurrency: 10,
      timeout: :infinity
    )
  end

  def get_user_ids_who_upload_posts() do
    UserEvent
    |> distinct([ue], ue.user_id)
    |> select([ue], ue.user_id)
    |> Repo.all()
  end

  def get_count_of_posts(user_id) do
    UserEvent
    |> where([ue], ue.user_id == ^user_id)
    |> select([ue], count(ue.id))
    |> Repo.one() || 0
  end

  #========================================================================
  # Functions for updating points for referring users
  #========================================================================

  def run_for_user_referrals(user_ids) do
    %RewardManager{id: reward_id, activity: remarks} = Data.Context.get_by(RewardManager, [activity_type: :sign_up_through_referral])
    Task.async_stream(
      user_ids,
      fn user_id ->
        count_of_total_referrals = get_count_of_referrals(user_id)
        count_of_reward_transactions = get_count_of_reward_transactions(user_id, reward_id)
        diff = count_of_total_referrals - count_of_reward_transactions
        diff = if diff <= 0, do: [], else: 1..diff |> Enum.to_list
        Enum.each(
          diff,
          fn _x ->
             Common.update_points(user_id, :sign_up_through_referral)
          end
        )
      end,
      max_concurrency: 10,
      timeout: :infinity
    )
  end

  defp get_users_who_reffered_someone() do
    UserReferral
    |> where([ur], ur.is_accept == true)
    |> distinct([ur], ur.referred_from_id)
    |> select([ur], ur.referred_from_id)
    |> Repo.all()
  end

  defp get_count_of_referrals(user_id) do
    UserReferral
    |> where([ur], ur.referred_from_id == ^user_id and ur.is_accept == true)
    |> select([ur], count(ur.id))
    |> Repo.one() || 0
  end

  #========================================================================
  # Functions for updating points for commenting on posts
  #========================================================================

  def run_for_comments(user_ids) do
    %RewardManager{id: reward_id, activity: remarks} = Data.Context.get_by(RewardManager, [activity_type: :commented_on_a_post])
    Task.async_stream(
      user_ids,
      fn user_id ->
        count_of_total_comments = get_count_of_comments(user_id)
        count_of_reward_transactions = get_count_of_reward_transactions(user_id, reward_id)
        diff = count_of_total_comments - count_of_reward_transactions
        diff = if diff <= 0, do: [], else: 1..diff |> Enum.to_list
        Enum.each(
          diff,
          fn _x ->
            Common.update_points(user_id, :commented_on_a_post)
          end
        )
      end,
      max_concurrency: 10,
      timeout: :infinity
    )
  end

  def get_user_ids_who_commented() do
    RoomMessage
    |> join(:inner, [rm], r in Room, on: r.id == rm.room_id and r.room_type == ^"event_comments")
    |> distinct([rm, _], rm.sender_id)
    |> select([rm, _], rm.sender_id)
    |> Repo.all()
  end

  defp get_count_of_comments(user_id) do
    RoomMessage
    |> join(:inner, [rm], r in Room, on: r.id == rm.room_id and r.room_type == ^"event_comments")
    |> where([rm, _], rm.sender_id == ^user_id)
    |> select([rm, _], count(rm.id))
    |> Repo.one() || 0
  end

  #========================================================================
  # Functions for updating points for liking posts
  #========================================================================

  def run_for_event_likes(user_ids) do
    %RewardManager{id: reward_id, activity: remarks} = Data.Context.get_by(RewardManager, [activity_type: :post_liked])
    Task.async_stream(
      user_ids,
      fn user_id ->
        count_of_total_comments = get_count_of_likes(user_id)
        count_of_reward_transactions = get_count_of_reward_transactions(user_id, reward_id)
        diff = count_of_total_comments - count_of_reward_transactions
        diff = if diff <= 0, do: [], else: 1..diff |> Enum.to_list
        Enum.each(
          diff,
          fn _x ->
            Common.update_points(user_id, :post_liked)
          end
        )
      end,
      max_concurrency: 10,
      timeout: :infinity
    )
  end

  def get_user_ids_who_liked_posts() do
    UserEventLike
    |> distinct([uel], uel.user_id)
    |> select([uel], uel.user_id)
    |> Repo.all()
  end

  defp get_count_of_likes(user_id) do
    UserEventLike
    |> where([uel], uel.user_id == ^user_id)
    |> select([uel], count(uel.id))
    |> Repo.one() || 0
  end

  #========================================================================
  # Functions for updating points for starting group chats
  #========================================================================

  def run_for_starting_group_chats(user_ids) do
    %RewardManager{id: reward_id, activity: remarks} = Data.Context.get_by(RewardManager, [activity_type: :started_new_group_conversation])
    Task.async_stream(
      user_ids,
      fn user_id ->
        count_of_total_comments = get_count_of_group_chats(user_id)
        count_of_reward_transactions = get_count_of_reward_transactions(user_id, reward_id)
        diff = count_of_total_comments - count_of_reward_transactions
        diff = if diff <= 0, do: [], else: 1..diff |> Enum.to_list
        Enum.each(
          diff,
          fn _x ->
            Common.update_points(user_id, :started_new_group_conversation)
          end
        )
      end,
      max_concurrency: 10,
      timeout: :infinity
    )
  end

  def get_user_ids_who_started_group_chat() do
    Room
    |> where([r], r.room_type == ^"group_chat" and not is_nil(r.created_by))
    |> distinct([r], r.created_by)
    |> select([r], r.created_by)
    |> Repo.all()
  end

  defp get_count_of_group_chats(user_id) do
    Room
    |> where([r],  r.room_type == ^"group_chat" and r.created_by == ^user_id)
    |> select([r], count(r.id))
    |> Repo.one() || 0
  end

  #========================================================================
  # Function for getting count of a specific reward for a specific user
  #========================================================================

  def get_count_of_reward_transactions(user_id, reward_id) do
    UserRewardTransaction
    |> where([urt], urt.reward_id == ^reward_id and urt.user_id == ^user_id)
    |> select([urt, _], count(urt.id))
    |> Repo.one() || 0
  end
end