defmodule Data.Helper.RewardManagerHelper do

  alias Data.Repo
  alias Data.Context
  alias Data.Context.{RewardManagers}
  alias Data.Schema.{RewardManager}

  import Ecto.Query

  def get_duplicate_activity_type() do
    dup = RewardManager
          |> select([rm], rm.activity_type)
          |> group_by([rm], rm.activity_type)
          |> having([rm], count(rm.id) > 1)
          |> Repo.all()

    RewardManager
    |> where([rm], rm.activity_type in ^dup)
    |> order_by([rm], [desc: rm.inserted_at])
    |> Repo.all()
    |> Enum.group_by(& &1.activity_type)
  end

  def remove_duplicates() do
    max = RewardManagers.get_max_activivty_type + 1
    dup = get_duplicate_activity_type
    Enum.reduce(dup, max, fn {k, v}, acc ->
      v = List.delete_at(v, 0)
      Enum.reduce(v, acc , fn reward, acc ->
        Context.update(RewardManager, reward, %{activity_type: acc})
        acc = acc + 1
      end)
    end)
  end
end