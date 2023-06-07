#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Filters.InterestsFilter do
  @moduledoc """
  Manage User Event Posts.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false

  use ApiWeb, :controller
  use Filterable.Phoenix.Controller
  use PhoenixSwagger

  alias Data.Context
  alias Data.Context.{UserEvents, RoomMessages, UserBlocks, UserInterests, NotificationsRecords}
  alias Data.Schema.{UserEvent, UserInterest, Room, RoomUser, User, UserEventImage, Interest}
  alias JetzyModule.AssetStore
  alias ApiWeb.Utils.Common
  alias Api.Workers.PushNotificationEventWorker
  alias Data.Repo
  #============================================================================
  # filterable
  #============================================================================
  filterable do
  #    paginateable(per_page: 20)
    @options default: ""
    filter base_query(query, _value, _conn) do
      query
    end

    @options param: [:event_start_date, :event_end_date]
    filter filter_by_dates(
             query,
             %{event_start_date: event_start_date, event_end_date: event_end_date},
             _conn
           ) do
      start_date = Date.from_iso8601!(event_start_date)
      end_date = Date.from_iso8601!(event_end_date)

      query
      |> where(
        [..., ue, _],
        fragment(
          "(? >= ? AND ? <= ?) OR (? >= ? AND ? <= ?)",
          ue.event_start_date,
          ^start_date,
          ue.event_start_date,
          ^end_date,
          ue.event_end_date,
          ^start_date,
          ue.event_end_date,
          ^end_date
        )
      )
    end

    @options param: [:event_start_time, :event_end_time]
    filter filter_by_time(
             query,
             %{event_start_time: event_start_time, event_end_time: event_end_time},
             _conn
           ) do
      start_time = Time.from_iso8601!(event_start_time)
      end_time = Time.from_iso8601!(event_end_time)

      query
      |> where(
           [..., ue, _],
           fragment(
             "(? >= ? AND ? <= ?) OR (? >= ? AND ? <= ?)",
             ue.event_start_time,
             ^start_time,
             ue.event_start_time,
             ^end_time,
             ue.event_end_time,
             ^start_time,
             ue.event_end_time,
             ^end_time
           )
         )
    end

    filter interests(query, value, _conn) do
      query
      |> order_by([i], [desc: i.id in ^Poison.decode!(value)])
    end
  end
end
