defmodule Data.Helper.FillShareableLinks do
  @moduledoc false
  alias Data.Repo, as: MyRepo
  alias Data.Schema.{Room, RewardOffer}
  alias ApiWeb.Utils.Common
  import Ecto.Query



  def generate_shareable_links_for_rooms(skip \\ 0, next \\ 100) do
    q = Room |> order_by([ue], [asc: ue.inserted_at]) |> limit(^next) |> offset(^skip)
    case MyRepo.all(q) do
      rows ->
        Enum.reduce(rows, %{}, fn row, _map ->
          sl = Common.generate_url("room", row.id)
          cs = %{shareable_link: sl}
          row
          |> Room.changeset(cs)
          |> MyRepo.insert_or_update
        end)
        if(Enum.count(rows)>0) do
          generate_shareable_links_for_rooms(next+skip, next)
        end
    end
  end

  def generate_shareable_links_for_rewards(skip \\ 0, next \\ 100) do
    q = RewardOffer |> order_by([ue], [asc: ue.inserted_at]) |> limit(^next) |> offset(^skip)
    case MyRepo.all(q) do
      rows ->
        Enum.reduce(rows, %{}, fn row, _map ->
          sl = Common.generate_url("reward", row.id)
          cs = %{shareable_link: sl}
          row
          |> RewardOffer.changeset(cs)
          |> MyRepo.insert_or_update
        end)
        if(Enum.count(rows)>0) do
          generate_shareable_links_for_rewards(next+skip, next)
        end
    end
  end

end
