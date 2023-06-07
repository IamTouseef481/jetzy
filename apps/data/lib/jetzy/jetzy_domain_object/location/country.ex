#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Location.Country do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "location-country"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  defmodule Entity do
    @nmid_index 99
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :status
      public_field :name
      public_field :details

      public_field :iso_3166_code
      public_field :flag_emoji

      public_field :geo, nil, Jetzy.GeoLocation.TypeHandler
      public_field :geo_geometry

      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end

    def by_name(country, context, options) do
      JetzySchema.Database.Location.Country.Table.match!(name: country)
      |> Amnesia.Selection.values()
      |> case do
           [h|_] -> h.entity
           _ ->
           if options[:auto] do
             time = options[:current_time] || DateTime.utc_now()
             %Jetzy.Location.Country.Entity{
               status: :active,
               name: country,
               time_stamp: Noizu.DomainObject.TimeStamp.Second.new(time, options)
             } |> Jetzy.Location.Country.Repo.create!(context, options)
           end
         end
    end

    def by_iso(iso, _context, _options) do
      JetzySchema.Database.Location.Country.Table.match!(iso_3166_code: iso)
      |> Amnesia.Selection.values()
      |> case do
           [h|_] -> h.entity
           _ -> nil
         end
    end


  end

end
