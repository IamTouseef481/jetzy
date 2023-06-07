defmodule Data.Context.UserEvents do
  import Ecto.Query, warn: false

  alias Data.Repo
  #  alias Data.Context
  alias Data.Schema.{
    UserEvent,
    User,
    UserInterest,
    Interest,
    RoomUser,
    UserFollow,
    ReportMessage,
    UserEventImage
  }

  alias ApiWeb.Utils.Common
  alias Data.Context.{UserInterests, UserBlocks}

  @spec preload_all(UserEvent.t()) :: UserEvent.t()
  def preload_all(data), do: Repo.preload(data, [:user, :interest, :room, :user_event_images])

  def guest_paginate(query, lat, long, distance_unit, interest_ids, page \\ 1, page_size \\ 10) do
    multiplication_factor =
      case distance_unit do
        "km" -> 0.621372736649807
        _ -> 1
      end

    interest_ids =
      Enum.map(interest_ids, fn x ->
        case Ecto.UUID.cast(x) do
          :error ->
            nil

          {:ok, v} ->
            v
            # UUID.string_to_binary!(v)
        end
      end)

    response =
      query
      |> join(:left, [q], rm in ReportMessage, on: rm.item_id == q.id and rm.is_deleted == false)
      #      |> order_by([q], desc: fragment("to_char(?, 'YYYY-MM-DD HH24')", q.inserted_at))
      |> order_by([q], desc: q.inserted_at)
      |> order_by([_], asc: fragment("distance"))
      |> order_by([q], desc: q.interest_id in ^interest_ids)
      # |> order_by([q], fragment("RANDOM()"))
      |> select([q, u], %UserEvent{
        id: q.id,
        # blur_hash: q.blur_hash,
        deleted_at: q.deleted_at,
        description: q.description,
        event_end_date: q.event_end_date,
        event_end_time: q.event_end_time,
        event_start_date: q.event_start_date,
        event_start_time: q.event_start_time,
        formatted_address: q.formatted_address,
        group_chat_room_id: q.group_chat_room_id,
        image: q.image,
        inserted_at: q.inserted_at,
        interest_id: q.interest_id,
        latitude: q.latitude,
        longitude: q.longitude,
        post_tags: q.post_tags,
        post_type: q.post_type,
        room_id: q.room_id,
        shareable_link_event: q.shareable_link_event,
        shareable_link_feed: q.shareable_link_feed,
        updated_at: q.updated_at,
        user_id: q.user_id,
        distance_unit: fragment("? as distance_unit", ^distance_unit),
        distance:
          fragment(
            #  "ST_DistanceSphere(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326)) as dist,
            "ceil((point(?,?) <@> point(?,?))/?) as distance",
            q.longitude,
            q.latitude,
            ^long,
            ^lat,
            ^multiplication_factor
          )
        # distance_slab: fragment(
        #      "case when ST_DistanceSphere(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326))<=10000 then 'A'
        #       when ST_DistanceSphere(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326))<=10000000 then 'B' else 'Z' end as distance_slab",
        #       q.latitude,
        #       q.longitude,
        #       ^lat,
        #       ^long,
        #       q.latitude,
        #       q.longitude,
        #       ^lat,
        #       ^long
        #    ),
      })
      |> group_by([q], q.id)
      |> having([_, _, rm], count(rm.id) == 0)
      |> Repo.paginate(page: page, page_size: page_size)
  end

  def paginate(
        query,
        lat,
        long,
        distance_unit,
        interest_ids,
        current_user_id \\ nil,
        page \\ 1,
        page_size \\ 10
      ) do
    follow_status = "followed"

    multiplication_factor =
      case distance_unit do
        "km" -> 0.621372736649807
        _ -> 1
      end

    interest_ids =
      Enum.map(interest_ids, fn x ->
        case Ecto.UUID.cast(x) do
          :error ->
            nil

          {:ok, v} ->
            v
            # UUID.string_to_binary!(v)
        end
      end)

    query =
      if List.first(interest_ids) do
        query |> where([q], q.interest_id in ^interest_ids)
      else
        query
      end

    response =
      query
      |> join(:left, [_, u], uf in UserFollow,
        on:
          uf.followed_id == u.id and uf.follower_id == ^current_user_id and
            uf.follow_status == ^follow_status
      )
      |> join(:left, [_, u], uf2 in UserFollow,
        on:
          uf2.follower_id == u.id and uf2.followed_id == ^current_user_id and
            uf2.follow_status == ^follow_status
      )
      |> join(:left, [q], rm in ReportMessage, on: rm.item_id == q.id and rm.is_deleted == false)
      # |> where([q], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", q.id))
      #      |> order_by([q], desc: fragment("to_char(?, 'YYYY-MM-DD HH24')", q.inserted_at))
      |> order_by([q], desc: q.inserted_at)
      |> order_by([_], asc: fragment("distance"))
      #      |> order_by([q], [desc: q.interest_id in ^interest_ids])
      |> order_by([_], asc: fragment("f"))
      # Added the below order_by for removing duplicates
      |> order_by([q, ...], desc: q.id)
      # |> order_by([q], [fragment("RANDOM()")])
      # |> select([q], q)
      |> select([q, u, uf, uf2], %UserEvent{
        id: q.id,
        blur_hash: q.blur_hash,
        deleted_at: q.deleted_at,
        description: q.description,
        event_end_date: q.event_end_date,
        event_end_time: q.event_end_time,
        event_start_date: q.event_start_date,
        event_start_time: q.event_start_time,
        formatted_address: q.formatted_address,
        group_chat_room_id: q.group_chat_room_id,
        image: q.image,
        inserted_at: q.inserted_at,
        interest_id: q.interest_id,
        latitude: q.latitude,
        longitude: q.longitude,
        post_tags: q.post_tags,
        post_type: q.post_type,
        room_id: q.room_id,
        shareable_link_event: q.shareable_link_event,
        shareable_link_feed: q.shareable_link_feed,
        updated_at: q.updated_at,
        user_id: q.user_id,
        distance_unit: fragment("? as distance_unit", ^distance_unit),
        distance:
          fragment(
            #  "ST_DistanceSphere(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326)) as dist,
            "ceil((point(?,?) <@> point(?,?))/?) as distance",
            q.longitude,
            q.latitude,
            ^long,
            ^lat,
            ^multiplication_factor
          ),
        followership:
          fragment(
            "case when ? is not null and ? is not null then 'A' else 'Z' end as f",
            uf.followed_id,
            uf2.followed_id
          )
      })
      |> group_by([ue, _u, uf, uf2], [ue.id, uf.id, uf2.id])
      |> having([_ue, _u, _uf, _uf2, rm], count(rm.id) == 0)
      |> Repo.paginate(page: page, page_size: page_size)

    response
  end

  # idea copied from room_messages.get_event_attendees
  def get_event_attendees(room_id, gc_room_id, user_id, page, page_size \\ 10) do
    blocked_user_ids = UserBlocks.get_blocked_user_ids(user_id)

    User
    |> join(:inner, [u], ru1 in RoomUser, on: ru1.room_id == ^room_id and u.id == ru1.user_id)
    |> join(:left, [u], ru2 in RoomUser, on: ru2.room_id == ^gc_room_id and u.id == ru2.user_id)
    |> where([u], u.id != ^user_id)
    |> where(
      [u],
      u.id not in ^blocked_user_ids and u.is_deleted == false and u.is_deactivated == false and
        u.is_self_deactivated == false
    )
    |> select([u, _ru, ru2], %{
      user_id: u.id,
      first_name: u.first_name,
      last_name: u.last_name,
      image_name: u.image_name,
      is_member: fragment("case when ? is not null then true else false end as f", ru2.user_id)
    })
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_events_by_user_id(user_id, page, page_size \\ 5) do
    UserEvent
    |> where([ue], ue.user_id == ^user_id and is_nil(ue.deleted_at))
    |> order_by([ue], desc: ue.inserted_at)
    |> preload([:user, :interest, :room, :user_event_images])
    # |> preload([:attendies])
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_my_feed_events_by_user_id(user_id, page, page_size \\ 10) do
    UserEvent
    |> where([ue], ue.user_id == ^user_id and is_nil(ue.deleted_at))
    |> order_by([ue], desc: ue.inserted_at)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  # def list_events_by(query, %{"user_latitude" => lat, "user_longitude" => long, "page"=> page, "page_size" => page_size}) do
  #   query
  #   |> join(:left, [q], rm in ReportMessage, on: rm.item_id == q.id and rm.is_deleted == false)
  #   # |> where([q], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", q.id))
  #   |> order_by(
  #        [ue],
  #        fragment(
  #          "ceil((point(?,?) <@> point(?,?)))",
  #          ue.longitude,
  #          ue.latitude,
  #          ^long,
  #          ^lat
  #        )
  #      )
  #   |> order_by([q], desc: q.inserted_at)
  #   |> Ecto.Query.preload([:user, :interest, :room, :user_event_images])
  #   |> select([q], q)
  #   |> Repo.paginate(page: page, page_size: page_size)
  #   # |> group_by([q], q.id)
  #   # |> having([_, _, rm], count(rm.id) == 0)
  #   # |> Repo.all()
  # end

  def list_events_by(query, %{"page" => page, "page_size" => page_size} = params) do
    interest_ids = params["interest_ids"] || []

    interest_ids =
      Enum.map(interest_ids, fn x ->
        case Ecto.UUID.cast(x) do
          :error -> nil
          {:ok, v} -> v
        end
      end)

    query =
      query
      |> join(:left, [q], rm in ReportMessage, on: rm.item_id == q.id and rm.is_deleted == false)
      # |> where([q], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", q.id))
      # |> order_by([q], desc: q.inserted_at)
      #    |> order_by([q], desc: fragment("to_char(?, 'YYYY-MM-DD HH24')", q.inserted_at))
      #    |> order_by([q], [desc: q.interest_id in ^interest_ids])
      |> order_by([q], fragment("RANDOM()"))
      |> Ecto.Query.preload([:user, :interest, :room, :user_event_images])
      |> select([q], q)
      |> group_by([q], q.id)
      |> having([_, _, rm], count(rm.id) == 0)

    query =
      if List.first(interest_ids) do
        query
        |> where([q], q.interest_id in ^interest_ids)
      else
        query
      end

    query
    |> Repo.paginate(page: page, page_size: page_size)

    # |> Repo.all()
  end

  #  defp add_rank(query) do
  #    from(g in query,
  #      windows: [p: [partition_by: q.interest_id, order_by: [desc: q.description]]],
  #      select_merge: %{group_rank: row_number() |> over(:p)}
  #    )
  #  end
  def get_nearby_events_by_interest_id(
        %{
          user_id: _user_id,
          interest_id: interest_id,
          lat: user_lat,
          long: user_long,
          page: page
        },
        page_size \\ 5
      ) do
    UserEvent
    |> join(:inner, [ue], u in User, on: u.id == ue.user_id)
    |> where(
      [ue, u],
      ue.interest_id == ^interest_id and is_nil(ue.deleted_at) and
        u.is_deleted == false and
        u.is_deactivated == false and u.is_self_deactivated == false
    )
    |> order_by(
      [ue],
      fragment(
        "ST_DistanceSphere(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326))",
        ue.latitude,
        ue.longitude,
        ^user_lat,
        ^user_long
      )
    )
    |> order_by([ue], desc: ue.inserted_at)
    |> Ecto.Query.preload([:user, :interest, :room, :user_event_images])
    |> select([ue], ue)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_nearby_events_by_interest_id_for_guest(
        %{"interest_id" => interest_id, "page" => page} = params,
        page_size \\ 10
      ) do
    if(Map.has_key?(params, "lat") && Map.has_key?(params, "long")) do
      order_by(
        UserEvent,
        [ue],
        fragment(
          "ST_DistanceSphere(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326))",
          ue.latitude,
          ue.longitude,
          ^Common.string_to_float(params["lat"]),
          ^Common.string_to_float(params["long"])
        )
      )
    else
      UserEvent
    end
    |> where([ue], ue.interest_id == ^interest_id)
    |> order_by([ue], desc: ue.inserted_at)
    |> Ecto.Query.preload([:user, :interest, :room, :user_event_images])
    |> select([ue], ue)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_user_events(interest_id, page, page_size \\ 10) do
    UserEvent
    |> join(:inner, [ue], u in Data.Schema.User, on: u.id == ue.user_id)
    |> where([ue], ue.interest_id == ^interest_id and is_nil(ue.deleted_at))
    |> select([ue, u], ue)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_room(id) do
    Data.Schema.Room
    |> where([r], r.id == ^id)
    |> limit(1)
    |> Repo.one()
  end

  def remove_attendee(event_id, user_id) do
    UserEvent
    |> join(:inner, [ue], ru in Data.Schema.RoomUser, on: ru.room_id == ue.room_id)
    |> where([ue, ru], ue.id == ^event_id and ru.user_id == ^user_id)
    |> select([ue, ru], ru)
    |> limit(1)
    |> Repo.one()
  end

  def get_user_by_event_id(event_id) do
    UserEvent
    |> join(:inner, [us], u in User, on: u.id == us.user_id)
    |> where([us, _], us.id == ^event_id)
    |> select([_, u], %{id: u.id, email: u.email})
    |> Repo.one()
  end

  def get_user_event_by_room_id(room_id) do
    UserEvent
    |> where([ue], ue.room_id == ^room_id)
    |> Repo.one()
  end

  def soft_delete_post(%UserEvent{} = event) do
    event
    |> UserEvent.changeset(%{deleted_at: DateTime.utc_now()})
    |> Repo.update()
  end

  def get_posts_for_admin(query, page, page_size) do
    query
    |> Ecto.Query.preload([:user, :interest, :user_event_images])
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_posts_within_radius(latitude, longitude, radius) do
    UserEvent
    |> where(
      [ue],
      fragment(
        "ST_DWithin(ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography, ? * 1609.34)",
        ue.latitude,
        ue.longitude,
        ^latitude,
        ^longitude,
        ^radius
      )
    )
    #    |> select([ue, uei], %{id: ue.id, latitude: ue.latitude, longitude: ue.longitude, description: ue.description})
    |> preload([:user_event_images])
    |> Repo.all()
  end

  def get_post_tags_ids_list(event_id) do
    UserEvent
    |> where([ue], ue.id == ^event_id)
    |> select([ue], ue.post_tags)
    |> Repo.one()
  end

  def user_for_post_tags(user_ids) do
    User
    |> where([u], u.id in ^user_ids)
    |> select([u], %{
      id: u.id,
      first_name: u.first_name,
      last_name: u.last_name,
      image_name: u.image_name,
      is_active: u.is_active,
      small_image_name: u.small_image_name
    })
    |> Repo.all()
  end

  def get_user_events_ids_by_user_id(user_id) do
    UserEvent
    |> where([ue], ue.user_id == ^user_id)
    |> select([ue], ue.id)
    |> Repo.all()
  end

  def delete_event_images(_, _, event_ids) do
    try do
      UserEventImage
      |> where([q], q.user_event_id in ^event_ids)
      |> Repo.update_all(set: [deleted_at: DateTime.utc_now()])

      {:ok, :success}
    rescue
      e ->
        {:error, e}
    end
  end

  def get_events(_filters) do
    from(ue in UserEvent)
    |> where([ue], not is_nil(ue.event_start_date))
    |> where([ue], not is_nil(ue.event_end_date))
    |> Repo.all()
  end
end
