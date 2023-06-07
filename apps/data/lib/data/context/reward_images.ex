defmodule Data.Context.RewardImages do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.RewardImage

  @spec preload_all(RewardImage.t()) :: RewardImage.t()
  def preload_all(data), do: Repo.preload(data, [:reward_offer, ])

  def get_images_by_reward_offer_id(reward_offer_id) do
    RewardImage
    |> where([rm], rm.reward_offer_id == ^reward_offer_id)
    |> Repo.all()
  end

end
