defmodule JetzyModule.JetzyPointsModule do
  @moduledoc """
  Manage jetzy point events.
  """

  @sign_up_reward "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b37"
  def sign_up_reward(user, _context, _options \\ []) do
    Context.create(UserRewardTransaction, %{point: 1000, balance_point: 1000, remarks: "Sign Up", user_id: user.identifier, reward_id: @sign_up_reward})
  end
  
end