#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------
defmodule Jetzy.User.Location.History do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "user-location-history"
  @persistence_layer :mnesia
  #@persistence_layer :ecto
  defmodule Entity do
    @derive Noizu.EctoEntity.Protocol
    @nmid_index 343
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :user
      
      public_field :geo, nil, Jetzy.GeoLocation.TypeHandler
      public_field :geo_geometry
      
      public_field :location
      public_field :check_in, nil, Jetzy.UserVersionedString.TypeHandler
      public_field :tagged #, nil, Jetzy.User.Repo.TypeHandler
      public_field :spoofed
      
      @index {:with, JetzySchema.Types.Visibility.Type.Enum}
      public_field :visibility
      
      public_field :logged_on, nil, Noizu.DomainObject.DateTime.Second.TypeHandler
      public_field :replaced_on, nil, Noizu.DomainObject.DateTime.Second.TypeHandler
      
      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
    
    
    # Hack
    def ecto_entity?(), do: true
    def supported?(_), do: true
    def source(_), do: __MODULE__
    def ecto_identifier({:ref, __MODULE__, id}), do: id
    def ecto_identifier(%__MODULE__{} = this), do: this.identifier
    
    #----------------------------
    #
    #----------------------------
    def existing!(%{__struct__: table, id: guid}, context, options) when table in [JetzySchema.MSSQL.User.Geo.Location.Table, JetzySchema.MSSQL.User.Geo.Location.Log.Table]   do
      cond do
        options[:existing] == false -> nil
        options[:existing] -> options[:existing]
        ref = Jetzy.LegacyResolution.Repo.by_type_and_legacy!(__MODULE__, table, guid, context, options) -> entity!(ref)
        :else -> nil
      end
    end
    def existing!(_, _, _), do: nil
    
    
    #----------------------------
    # __from_record__
    #----------------------------
    def __from_record__(layer, record, context, options \\ nil)
    def __from_record__(%{__struct__: PersistenceLayer, schema: JetzySchema.MSSQL.Repo} = _layer, %{__struct__: JetzySchema.MSSQL.User.Geo.Location.Table} = record, context, options) do
      existing = existing!(record, context, options)
      user = options[:user] || Jetzy.User.Repo.by_guid!(record.user, context, options)
      geo = Jetzy.GeoLocation.new({record.latitude, record.longitude})
      geo_geometry = existing && existing.geo_geometry # || record.geo_location # todo cast from record.geo_location
      spoofed = !record.is_actual_location
      location = Jetzy.Location.City.Repo.by_legacy_city!(record.city, context, options) || existing && existing.location
      check_in = existing && existing.check_in || (case record.location do
                                                     nil -> nil
                                                     "" -> nil
                                                     v when is_bitstring(v) -> %{title: "Check In", body: v, editor: Noizu.ERP.ref(user)}
                                                     _ -> nil
                                                   end)
      tagged = existing && existing.tagged
      visibility = existing && existing.visibility || :public
      logged_on = record.created_on && DateTime.truncate(record.created_on, :second)
      
      time_stamp = record.__struct__.time_stamp(record, context, options)
      meta = (existing && existing.meta || [])
             |> put_in([:source], {record.__struct__, record.id})
      meta = cond do
               location -> meta
               record.city -> put_in(meta, [:import_legacy_city], {record.__struct__, record.id, record.city})
               :else -> meta
             end
#      meta = cond do
#               geo_geometry -> meta
#               record.geo_location -> put_in(meta, [:import_geo], {record.__struct__, record.id, record.geo_location})
#               :else -> meta
#             end
      
      %Jetzy.User.Location.History.Entity{existing || %Jetzy.User.Location.History.Entity{}|
        user: Noizu.ERP.ref(user),
        
        geo: geo,
        geo_geometry: geo_geometry,
        
        location: location,
        check_in: check_in,
        tagged: tagged,
        spoofed: spoofed,
        
        visibility: visibility,
        
        logged_on: logged_on,
        time_stamp: time_stamp,
        
        __transient__: [partials: true, legacy: record],
        meta: meta
      }
    end
    def __from_record__(%{__struct__: PersistenceLayer, schema: JetzySchema.MSSQL.Repo} = _layer, %{__struct__: JetzySchema.MSSQL.User.Geo.Location.Log.Table} = record, context, options) do
      existing = existing!(record, context, options)
      user = options[:user] || Jetzy.User.Repo.by_guid!(record.user, context, options)
      geo = Jetzy.GeoLocation.new({record.latitude, record.longitude})
      geo_geometry = existing && existing.geo_geometry # || record.geo_location # todo cast from record.geo_location
      spoofed = !record.is_actual_location
      check_in = existing && existing.check_in || (case record.location do
                                                     nil -> nil
                                                     "" -> nil
                                                     v when is_bitstring(v) -> %{title: "Check In", body: v, editor: Noizu.ERP.ref(user)}
                                                     _ -> nil
                                                   end)
      visibility = existing && existing.visibility || :public
      logged_on = record.created_on && DateTime.truncate(record.created_on, :second)
      
      
      time_stamp = record.__struct__.time_stamp(record, context, options)
      meta = (existing && existing.meta || [])
             |> put_in([:source], {record.__struct__, record.id})
#      meta = cond do
#               geo_geometry -> meta
#               record.geo_location -> put_in(meta, [:import_geo], {record.__struct__, record.id, record.geo_location})
#               :else -> meta
#             end
      %Jetzy.User.Location.History.Entity{existing || %Jetzy.User.Location.History.Entity{}|
        user: Noizu.ERP.ref(user),
        
        geo: geo,
        geo_geometry: geo_geometry,
        
        check_in: check_in,
        spoofed: spoofed,
        
        visibility: visibility,
        
        logged_on: logged_on,
        time_stamp: time_stamp,
        
        __transient__: [partials: true, legacy: record],
        meta: meta
      }
    end
    def __from_record__(layer, record, context, options), do: super(layer, record, context, options)
  end # End Entity
  
  
  defmodule Repo do
    require Logger
    Noizu.DomainObject.noizu_repo do
    end

    #--------------------------------
    #
    #--------------------------------
    def post_create_callback(entity, context, options) do
      with {:ok, {:ref, _, id} = ref} <- Noizu.ERP.ref_ok(entity),
           true <- id != nil,
           {table, table_id} <- entity.meta[:source] do
        cond do
          table in [JetzySchema.MSSQL.User.Geo.Location.Table, JetzySchema.MSSQL.User.Geo.Location.Log.Table] -> Jetzy.LegacyResolution.Repo.insert_guid(ref, table, table_id, context, options)
          table in [Data.Schema.UserGeoLocation, Data.Schema.UserGeoLocationLog] -> Jetzy.TanbitsResolution.Repo.insert_guid(ref, table, table_id, context, options)
          :else -> :skip
        end
      end
      super(entity, context, options)
    end
    def post_create_callback!(entity, context, options) do
      with {:ok, {:ref, _, id} = ref} <- Noizu.ERP.ref_ok(entity),
           true <- id != nil,
           {table, table_id} <- entity.meta[:source] do
        cond do
          table in [JetzySchema.MSSQL.User.Geo.Location.Table, JetzySchema.MSSQL.User.Geo.Location.Log.Table] -> Jetzy.LegacyResolution.Repo.insert_guid!(ref, table, table_id, context, options)
          table in [Data.Schema.UserGeoLocation, Data.Schema.UserGeoLocationLog] -> Jetzy.TanbitsResolution.Repo.insert_guid!(ref, table, table_id, context, options)
          :else -> :skip
        end
      end
      super(entity, context, options)
    end

    #-------------------------------------------
    #
    #-------------------------------------------
    def import_tanbits_analog(imported, %JetzySchema.MSSQL.User.Geo.Location.Table{} = record, context, options) do
      cond do
        existing = Data.Repo.get_by(Data.Schema.UserGeoLocation, user_id: record.user) ->
          case existing do
            %Data.Schema.UserGeoLocation{} ->
              #Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(imported), Data.Schema.UserGeoLocation, existing.id, context, options)
              {:ok, existing}
            :else -> {:error, {:fetch_by_guid_error, {Noizu.ERP.ref(imported), record, existing}}}
          end
        :else -> {:ok, nil}
      end
      |> case do
           {:ok, existing} ->
             {lat, lng} = case imported.geo do
                            %{coordinates: {lat,lng}} -> {lat,lng}
                            _ -> {nil, nil}
                          end
             update = %Data.Schema.UserGeoLocation{existing || struct(Data.Schema.UserGeoLocation,[])|
               geo_location: nil, # imported.geo_geometry,
               is_actual_location: !imported.spoofed,
               latitude: lat,
               longitude: lng,
               location: record.location,
               user_id: record.user,
               city_lat_long_id: record.city,
               inserted_at: imported.time_stamp.created_on,
               updated_at: imported.time_stamp.modified_on,
               deleted_at: imported.time_stamp.deleted_on,
             }
             cond do
               existing ->
                 update = Data.Repo.update(Data.Schema.UserGeoLocation.changeset(record))
                 {:updated, update}
               :else ->
                 with {:ok, updated} <- Data.Repo.upsert(update) do
                   Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(imported), Data.Schema.UserGeoLocation, updated.id, context, options)
                   {:inserted, updated}
                 else
                   pg -> {:error, {:persist, imported, record, pg}}
                 end
             end
           error -> error
         end
    end



    #-------------------------------------------
    #
    #-------------------------------------------
    def import_tanbits_analog(imported, %JetzySchema.MSSQL.User.Geo.Location.Log.Table{} = record, context, options) do
      cond do
        tanbits_ref = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.UserGeoLocationLog, Noizu.ERP.ref(imported), context, options) ->
          cond do
            existing = Noizu.ERP.entity!(tanbits_ref) -> {:ok, existing}
            :else -> {:error, {:lookup_table_corruption, {Noizu.ERP.ref(imported), record, tanbits_ref}}}
          end
        existing = Data.Repo.get(Data.Schema.UserGeoLocationLog, record.id) ->
          case existing do
            %Data.Schema.UserGeoLocationLog{} ->
              Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(imported), Data.Schema.UserGeoLocationLog, existing.id, context, options)
              {:ok, existing}
            :else -> {:error, {:fetch_by_guid_error, {Noizu.ERP.ref(imported), record, existing}}}
          end
        :else -> {:ok, nil}
      end
      |> case do
           {:ok, existing} ->
             {lat, lng} = case imported.geo do
                            %{coordinates: {lat,lng}} -> {lat,lng}
                            _ -> {nil, nil}
                          end
             update = %Data.Schema.UserGeoLocationLog{existing || struct(Data.Schema.UserGeoLocationLog,[])|
               geo_location: nil, #imported.geo_geometry,
               is_actual_location: !imported.spoofed,
               latitude: lat,
               longitude: lng,
               location: record.location,
               user_id: record.user,
               inserted_at: imported.time_stamp.created_on,
               updated_at: imported.time_stamp.modified_on,
               deleted_at: imported.time_stamp.deleted_on,
             }
             cond do
               existing ->
                 update = Data.Repo.update(Data.Schema.UserGeoLocationLog.changeset(update))
                 {:updated, update}
               :else ->
                 with {:ok, updated} <- Data.Repo.upsert(update) do
                   Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(imported), Data.Schema.UserGeoLocationLog, updated.id, context, options)
                   {:inserted, updated}
                 else
                   pg -> {:error, {:persist, imported, record, pg}}
                 end
             end
           error -> error
         end
    end
    
    
    #-------------------------------------------
    #
    #-------------------------------------------
    def import!(%{__struct__: table} = record, context, options) when table in [JetzySchema.MSSQL.User.Geo.Location.Table, JetzySchema.MSSQL.User.Geo.Location.Log.Table] do
      Logger.info "Importing User Geo Record - #{inspect record.id}"
      existing = Jetzy.LegacyResolution.Repo.by_type_and_legacy!(Jetzy.User.Location.History.Entity, table, record.id, context, options)
      existing = existing && (get!(Jetzy.User.Location.History.Entity.id(existing), context, options) || throw "Unable to continue, missing record #{inspect existing}")

      options_b = (options || [])
                  |> put_in([:existing], existing || false)
      
      cond do
        existing && !options[:refresh] -> {:error, {:already_imported, Noizu.ERP.ref(existing)}}
        entity = Jetzy.User.Location.History.Entity.__from_record__(%PersistenceLayer{schema: JetzySchema.MSSQL.Repo}, record, context, options_b) ->
          response = cond do
            !entity -> {:error, {:create, :failure, entity}}
            existing ->
              imported = update!(entity, context, options)
              options[:import_tanbits] && {:refreshed, {Noizu.ERP.ref(imported), import_tanbits_analog(imported, record, context, options)}} || {:refresh, {Noizu.ERP.ref(imported), nil}}
            entity ->
              imported = create!(entity, context, options)
              options[:import_tanbits] && {:imported, {Noizu.ERP.ref(imported), import_tanbits_analog(imported, record, context, options)}} || {:imported, {Noizu.ERP.ref(imported), nil}}
          end
      end
    rescue
      error ->
        Logger.error "exception raised #{inspect record.id} | #{Exception.format(:error, error, __STACKTRACE__)}"
        {:raise, record.id}
    catch
      error ->
        Logger.error "exception raised #{inspect record.id} | #{Exception.format(:error, error, __STACKTRACE__)}"
        {:raise, record.id}
      _,error ->
        Logger.error "exception raised #{inspect record.id} | #{Exception.format(:error, error, __STACKTRACE__)}"
        {:raise, record.id}
    end # end import!
    
    
  end # End Repo
end