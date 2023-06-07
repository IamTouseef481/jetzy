#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Location.Place do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "location-place"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  defmodule Entity do
    @nmid_index 101
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      @index true
      public_field :location_country, nil, Jetzy.Location.Country.TypeHandler

      @index true
      public_field :location_state, nil, Jetzy.Location.State.TypeHandler

      @index true
      public_field :location_city, nil, Jetzy.Location.City.TypeHandler

      @index true
      public_field :location_type

      @index true
      public_field :status

      @index true
      public_field :address, nil, Jetzy.VersionedAddress.TypeHandler

      @index true
      public_field :place_key

      @index true
      public_field :details

      public_field :geo, nil, Jetzy.GeoLocation.TypeHandler
      public_field :geo_geometry

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end



    def new({:google_place, google_place}, context, options) do
      address = Jetzy.VersionedAddress.Entity.new({:google_place, google_place}, context, options)
      now = options[:current_time] || DateTime.utc_now()
      %__MODULE__{
        location_country: address.address_country,
        location_state: address.address_state,
        location_city: address.address_city,
        location_type: :google,
        status: :active,
        address: address,
        place_key: google_place["place_id"],
        time_stamp: Noizu.DomainObject.TimeStamp.Second.new(now, options)
      }
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end

    def by_place_key(key, _context, _options) do
      JetzySchema.Database.Location.Place.Table.match!([place_key: key])
      |> Amnesia.Selection.values()
      |> case do
         [h|_] -> {:ok, h.entity}
         _ -> nil
         end
    end

    def by_address_string!(address, {lng,lat}, _context, _options) do
      with {:ok, response} <- GoogleMaps.place_query(address) do
        nearest = Enum.map(response["predictions"], fn(response) ->
          {:ok, p} = GoogleMaps.place_details(response["place_id"])
          p
        end) |> Enum.sort(fn(a,b) ->
          a_lat = abs(a["result"]["geometry"]["location"]["lat"] - lat)
          a_lng = abs(a["result"]["geometry"]["location"]["lng"] - lng)
          a_metric_distance = max(a_lat, a_lng)

          b_lat = abs(b["result"]["geometry"]["location"]["lat"] - lat)
          b_lng = abs(b["result"]["geometry"]["location"]["lng"] - lng)
          b_metric_distance = max(b_lat, b_lng)
          a_metric_distance < b_metric_distance
        end) |> List.first()
        nearest && {:ok, nearest["result"]} || {:error, {:no_match, address}}
      end
    end
  end
end
