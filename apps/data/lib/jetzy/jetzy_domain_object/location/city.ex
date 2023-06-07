#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Location.City do
  use Noizu.DomainObject
  @vsn 1.1
  @sref "location-city"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  defmodule Entity do
    @nmid_index 98
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :location_state
      public_field :location_country
      public_field :status
      public_field :name
      public_field :details
      
      public_field :geo, nil, Jetzy.GeoLocation.TypeHandler
      public_field :geo_geometry
      
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end # End Entity
  
  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    
    end
    
    #--------------------------------
    #
    #--------------------------------
    def update_vsn(%{vsn: 1.0} = entity, context, options) do
      entity
      |> put_in([Access.key(:geo)], nil)
      |> put_in([Access.key(:geo_geometry)], nil)
      |> put_in([Access.key(:vsn)], 1.1)
      |> update!(context, options)
    end
    def update_vsn(entity, _,_), do: entity
    
    #--------------------------------
    #
    #--------------------------------
    def update_vsn!(%{vsn: 1.0} = entity, context, options) do
      entity
      |> put_in([Access.key(:geo)], nil)
      |> put_in([Access.key(:geo_geometry)], nil)
      |> put_in([Access.key(:vsn)], 1.1)
      |> update!(context, options)
    end
    def update_vsn!(entity, _,_), do: entity
    
    #--------------------------------
    #
    #--------------------------------
    def post_get_callback(entity, context, options) do
      entity
      |> update_vsn(context, options)
      |> super(context, options)
    end
    def post_get_callback!(entity, context, options) do
      entity
      |> update_vsn(context, options)
      |> super(context, options)
    end
    
    #--------------------------------
    #
    #--------------------------------
    def by_legacy_city!(city_lat_lng_guid, _context, _options) do
      # insure cities are laoded up before we import things for tanbits, will add actual vnext city setup after release
      cond do
        !city_lat_lng_guid -> nil
        existing = Data.Repo.get(Data.Schema.CityLatLong, city_lat_lng_guid) -> Noizu.ERP.ref(existing)
        import = JetzySchema.MSSQL.Repo.get(JetzySchema.MSSQL.CityLatLong.Table, city_lat_lng_guid) ->
          record = %Data.Schema.CityLatLong{
            id: import.id,
            city: import.city,
            state: import.state,
            country: import.country,
            zip_code: import.zip_code,
            location: import.location,
            latitude: import.latitude && Decimal.to_float(import.latitude),
            longitude: import.longitude && Decimal.to_float(import.longitude),
            inserted_at: import.created_on && DateTime.truncate(import.created_on, :second),
            updated_at: import.modified_on && DateTime.truncate(import.modified_on, :second),
            deleted_at: nil
          }
          with {:ok, record} <- Data.Repo.upsert(record) do
            Noizu.ERP.ref(record)
          else
            error ->
              Logger.error("Error: #{inspect error, pretty: true}")
              nil
          end
      end
    end
    
    #--------------------------------
    #
    #--------------------------------
    def by_city_country(city, country, context, options) do
      country = Jetzy.Location.Country.Repo.by_name(context, context, options)
      country = Noizu.ERP.ref(country)
      JetzySchema.Database.Location.Country.Table.match!([name: city, country: country])
      |> Amnesia.Selection.values()
      |> case do
           [h|_] -> h.entity
           _ ->
             if options[:auto] do
               time = options[:current_time] || DateTime.utc_now()
               %Jetzy.Location.City.Entity{
                 status: :active,
                 name: city,
                 location_state: nil,
                 location_country: country,
                 time_stamp: Noizu.DomainObject.TimeStamp.Second.new(time, options)
               } |> Jetzy.Location.City.Repo.create!(context, options)
             end
         end
    end
    
    #--------------------------------
    #
    #--------------------------------
    def by_name(city, state, country, context, options) do
      country = Noizu.ERP.ref(country)
      state = Noizu.ERP.ref(state)
      JetzySchema.Database.Location.Country.Table.match!(name: city, state: state, country: country)
      |> Amnesia.Selection.values()
      |> case do
           [h|_] -> h.entity
           _ ->
             if options[:auto] do
               time = options[:current_time] || DateTime.utc_now()
               %Jetzy.Location.City.Entity{
                 status: :active,
                 name: city,
                 location_state: state,
                 location_country: country,
                 time_stamp: Noizu.DomainObject.TimeStamp.Second.new(time, options)
               } |> Jetzy.Location.City.Repo.create!(context, options)
             end
         end
    end
  end # end Repo
end # end DomainObject
