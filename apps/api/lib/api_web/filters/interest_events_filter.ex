#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Filters.InterestEventsFilter do
  @moduledoc """
  Manage Interest Event Posts.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  use Filterable.Phoenix.Controller
  import Ecto.Query, warn: false
  alias Data.Repo
  #============================================================================
  # filterable
  #============================================================================
  filterable do

    @options param: :interest_id
    filter base_query(query, interest_id, _conn) do
      query
      |> where([ue], ue.interest_id == ^interest_id)
      |> where([ue], is_nil(ue.deleted_at))
      |> where([ue], fragment("(select count(id) from report_messages where report_messages.item_id = ? and is_deleted = false) = 0", ue.id))
      |> select([ue], ue)
    end

    @options param: [:lat, :long], cast: :float
    filter filter_by_location(
             query,
             %{lat: lat, long: long},
             _conn
           ) do
      query
      |> order_by(
           [ue],
           fragment(
             "ST_DistanceSphere(ST_SetSRID(ST_MakePoint(?, ?), 4326), ST_SetSRID(ST_MakePoint(?, ?), 4326))",
             ue.latitude,
             ue.longitude,
             ^lat,
             ^long
           )
         )
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
        [ue],
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
           [ue],
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
  end

end
