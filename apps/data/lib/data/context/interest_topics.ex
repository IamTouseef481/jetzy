defmodule Data.Context.InterestTopics do
  import Ecto.Query, warn: false

  alias Data.Repo
  alias Data.Schema.{InterestTopic, RoomUser, User}
  alias Data.Context.{UserBlocks, RoomUsers}

  def list_topics_by_interest(interest_id) do
    from(t in InterestTopic,
    where: t.interest_id == ^interest_id,
    preload: :created_by)
    |> Repo.all()
  end

  def update(interest_topic, attrs) do
    interest_topic
    |> InterestTopic.update_changeset(attrs)
    |> Repo.update()
  end

  @spec preload_all(InterestTopic.t()) :: InterestTopic.t()
  def preload_all(data), do: Repo.preload(data, [:interest, :room, :user])

  def get_interest_topics_by_interest_id(user_id, interest_id, page, page_size \\ 10) do
    Data.Schema.InterestTopic
    |> join(:left, [ui], rm in Data.Schema.RoomMessage, on: rm.room_id == ui.room_id )
    |> join(:inner, [ui, rm], ru in Data.Schema.RoomUser, on: ru.room_id == ui.room_id )
    |> where([_ui, _rm, ru], ru.user_id == ^user_id)
    |> where([ui], ui.interest_id == ^interest_id)
    |> order_by([_, rm, _], [rm.message])
    |> order_by([_, rm, _], [desc: rm.inserted_at])
    |> order_by([ui, _, _], [desc: ui.inserted_at])
    |> distinct([ui, _, _], ui.id)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_all_members_list_interest_topic(%{room_id: room_id, user_id: user_id, page: page}, page_size \\ 10)do

    blocked_user_ids = UserBlocks.get_blocked_user_ids(user_id)

    from(ru in RoomUser,
    join: u in User,
    on: u.id == ru.user_id,
    where: ru.room_id == ^room_id,
    where: ru.user_id not in ^blocked_user_ids and u.is_deleted == false and u.is_deactivated == false and u.is_self_deactivated == false,
    preload: [:user, :room])
    |>Repo.paginate(page: page, page_size: page_size)
  end

  def delete_interest_topic_by_user_id(_, _, created_by_id) do
    interest_topics =
      InterestTopic
      |> where([i], i.created_by_id == ^created_by_id)
      |> Repo.all()

    try do
      Enum.each(interest_topics, fn interest_topic ->
        if RoomUsers.room_user_exists?(interest_topic.room_id) do
          old_user_id = RoomUsers.get_oldest_room_user(interest_topic.room_id)
          Context.update(InterestTopic, interest_topic, %{created_by: old_user_id})
        else
          Context.update(InterestTopic, interest_topic, %{deleted_at: DateTime.utc_now()})
        end
      end)
      {:ok, :success}
    rescue
      e ->
        {:error, e}
    end

  end
end
