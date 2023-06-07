#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Location.State do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "location-state"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  defmodule Entity do
    @nmid_index 106
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :location_country
      public_field :status
      public_field :name
      public_field :details

      public_field :geo, nil, Jetzy.GeoLocation.TypeHandler
      public_field :geo_geometry

      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end



    def by_name(state, country, context, options) do
      country = Noizu.ERP.ref(country)
      JetzySchema.Database.Location.Country.Table.match!(name: state, country: country)
      |> Amnesia.Selection.values()
      |> case do
           [h|_] -> h.entity
           _ ->
             if options[:auto] do
               time = options[:current_time] || DateTime.utc_now()
               %Jetzy.Location.State.Entity{
                 status: :active,
                 name: state,
                 location_country: country,
                 time_stamp: Noizu.DomainObject.TimeStamp.Second.new(time, options)
               } |> Jetzy.Location.State.Repo.create!(context, options)
             end
         end
    end
  end

end
