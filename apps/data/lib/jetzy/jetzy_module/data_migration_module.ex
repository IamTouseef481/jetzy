defmodule JetzyModule.DataMigrationModule do
  use Data.Migration
  alias Data.Schema.{UserEvent, User}
  alias Data.Repo, as: MyRepo
  alias ApiWeb.Utils.Common
  import Ecto.Query
  
  def generate_shareable_links_for_events(skip \\ 0, next \\ 5000) do
    q = UserEvent |> order_by([ue], [asc: ue.inserted_at]) |> limit(^next) |> offset(^skip)
    case MyRepo.all(q) do
      rows ->
        Task.async_stream(rows, fn row ->
          sle = Common.generate_url("event", row.id)
          slf = Common.generate_url("feed", row.id)
          cs = %{shareable_link_event: sle, shareable_link_feed: slf}
          row
          |> UserEvent.changeset(cs)
          |> MyRepo.insert_or_update
          :ok
        end, max_concurrency: 16) |> Enum.map(&(&1))
        if(Enum.count(rows)>0) do
          generate_shareable_links_for_events(next+skip, next)
        end
    end
  end

  def generate_shareable_links_for_users(skip \\ 0, next \\ 5000) do
    q = User |> order_by([ue], [asc: ue.inserted_at]) |> limit(^next) |> offset(^skip)
    case MyRepo.all(q) do
      rows ->
        Task.async_stream(rows, fn row ->
          sl = Common.generate_url("user", row.id)
          cs = %{shareable_link: sl}
          row
          |> User.changeset(cs)
          |> MyRepo.insert_or_update
          :ok
        end, max_concurrency: 16) |> Enum.map(&(&1))
        if(Enum.count(rows)>0) do
          generate_shareable_links_for_users(next+skip, next)
        end
    end
  end
  
end