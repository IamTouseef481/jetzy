#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Post do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "post"
  @persistence_layer {:mnesia, cascade?: true, cascade_block?: true}
  @persistence_layer {:ecto, cascade?: true, cascade_block?: true}
  @persistence_layer {Data.Repo, Data.Schema.UserEvent, [cascade?: true, sync: false, fallback?: false, cascade_block?: true]}
  @persistence_layer {JetzySchema.MSSQL.Repo, [sync: false]}
  @index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]]}
  # Pending Implementation: @index {Jetzy.Admin.Index, pii: :level_0, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]}
  defmodule Entity do
    @nmid_index 113
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      @index true
      public_field :owner, nil, Noizu.DomainObject.UUID.UniversalLink.TypeHandler

      public_field :snippet, nil, Jetzy.PostVersionedString.TypeHandler

      @index true
      public_field :content, nil, Jetzy.CMS.Article.Post.TypeHandler

      @index true
      public_field :location, nil, Jetzy.Location.Place.TypeHandler

      @index true
      public_field :geo, nil, Jetzy.GeoLocation.TypeHandler

      @index {:with, JetzySchema.Types.Post.Topic.Enum}
      public_field :post_topic

      @index {:with, JetzySchema.Types.Post.Type.Enum}
      public_field :post_type

      @index {:with, JetzySchema.Types.Media.Type.Enum}
      public_field :media_type

      @index {:with, JetzySchema.Types.Visibility.Type.Enum}
      public_field :visibility

      public_field :sharing, nil, Jetzy.Entity.Share.Repo.TypeHandler

      @index {:with, JetzySchema.Types.Status.Enum}
      public_field :status

      @index true
      public_field :interests, nil, Jetzy.Post.Interest.Repo.TypeHandler

      @index true
      public_field :tags, nil, Jetzy.Post.Tag.Repo.TypeHandler

      @ref Jetzy.Entity.Interactions.Entity
      public_field :interactions, nil, Jetzy.Entity.Interactions.TypeHandler
      # @index true
      transient_field :children

      @index true
      public_field :moderation, nil, Jetzy.ModerationDetails.TypeHandler

      public_field :event_start_date, nil
      public_field :event_start_time, nil

      public_field :event_end_date, nil
      public_field :event_end_time, nil

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end



    #----------------------------
    # __from_record__
    #----------------------------
    def __from_record__(layer, record, context, options \\ nil)
    def __from_record__(%{__struct__: PersistenceLayer, schema: JetzySchema.MSSQL.Repo} = _layer, %{__struct__: JetzySchema.MSSQL.Post.Table} = record, context, options) do

      existing = cond do
                   options[:existing] == false -> nil
                   options[:existing] -> options[:existing]
                   existing_entity = Jetzy.LegacyResolution.Repo.by_legacy(JetzySchema.MSSQL.Post.Table, record.id, context, options) ->
                     Jetzy.Post.Repo.get(Noizu.ERP.id(existing_entity), context, options)
                   :else -> nil
                 end

      #--------------
      user = Jetzy.User.Repo.by_guid!(record.user, context, options)

      post_topic = JetzySchema.MSSQL.Post.Table.topic(record, context, options)
      time_stamp = JetzySchema.MSSQL.Post.Table.time_stamp(record, context, options)
      media_type = JetzySchema.MSSQL.Post.Table.media_type(record, context, options)

      # Check for existing / change
      record_title = Jetzy.Helper.get_sanitized_string(record.title, :post_title, existing, record, context)
      record_description = Jetzy.Helper.get_sanitized_string(record.description || "", :post_body, existing, record, context)

      snippet = Jetzy.PostVersionedString.TypeHandler.sync(
        existing && existing.snippet,
        %{title: record_title, body: String.slice(record_description || "", 0..128), editor: user, modified_on: time_stamp.modified_on},
        context,
        options
      )

      # Check for existing / change
      media = JetzySchema.MSSQL.Post.Table.media(record, context, options)
      media = media && [{:image, {:import, {:post, media}}}] || []
      content = Jetzy.CMS.Article.Post.TypeHandler.sync(
        existing && existing.content,
        %{title: record_title, body: record_description, media: media, editor: user, time_stamp: time_stamp},
        context,
        options
      )
      post_type = JetzySchema.MSSQL.Post.Table.type(record, context, options)
      status = JetzySchema.MSSQL.Post.Table.status(record, context, options)

      location = Jetzy.Location.Place.TypeHandler.sync(existing && existing.location, JetzySchema.MSSQL.Post.Table.location(record, context, options), context, options)
      interests = Jetzy.Post.Interest.Repo.TypeHandler.sync(existing && existing.interests, JetzySchema.MSSQL.Post.Table.interests(record, context, options), context, options)
      tags = Jetzy.Post.Tag.TypeHandler.sync(existing && existing.tags, JetzySchema.MSSQL.Post.Table.tags(record, context, options), context, options)
      sharing = Jetzy.Entity.Share.Repo.TypeHandler.sync(existing && existing.sharing, JetzySchema.MSSQL.Post.Table.sharing(record, context, options), context, options)
      visibility = cond do
                     !record.is_shared -> :private
                     sharing == nil -> :public
                     sharing.entities == nil -> :public
                     sharing.entities == [] -> :public
                     sharing.entities -> :select
                   end


      moderation = existing && existing.moderation || %Jetzy.ModerationDetails{}
      #--------------
      interactions = %{}

      %Jetzy.Post.Entity{
        owner: user,
        snippet: snippet,
        content: content,
        location: location,
        geo: Jetzy.GeoLocation.new({record.latitude, record.longitude}, 0.1),
        post_topic: post_topic,
        post_type: post_type,
        media_type: media_type,
        visibility: visibility,
        sharing: sharing,
        status: status,
        interests: interests,
        tags: tags,
        interactions: interactions,
        moderation: moderation,
        time_stamp: time_stamp,
        __transient__: %{
          partials: true,
          record: record,
          existing: existing
        },
        meta: [guid: record.guid, source: :legacy]
      }
    end
    def __from_record__(layer, record, context, options) do
      super(layer, record, context, options)
    end



    #===-------
    # has_permission?
    #===-------
    def has_permission?(_entity, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_entity, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

    #===-------
    # has_permission!
    #===-------
    def has_permission!(_entity, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_entity, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true


  end

  defmodule Repo do
    require Logger
    Noizu.DomainObject.noizu_repo do
    end

    #----------------------------
    # layer_create
    #----------------------------
    def layer_create(%{__struct__: PersistenceLayer, schema: Data.Repo} = layer, entity, context, options) do
      layer_create!(layer, entity, context, options)
    end
    def layer_create(layer, entity, context, options) do
      super(layer, entity, context, options)
    end

    #----------------------------
    # layer_create!
    #----------------------------
    def layer_create!(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do
      content = Noizu.ERP.entity!(entity.content)
      {lng,lat} = case entity.geo do
                    %{coordinates: {lat, lng}} -> {lng, lat}
                    _ -> {nil, nil}
                  end
      user = Jetzy.User.Guid.Lookup.Repo.by_user!(entity.owner, context)
      {image_identifier, media, media_thumb, blur_hash} = (with %{media: %{entities: [h|_]}} <- content do
                                           Jetzy.Entity.Image.Entity.image_thumb_hash(h, context, options)
                                         else
                                           _ -> {nil, nil, nil, nil}
                                         end)

      record = %Data.Schema.UserEvent{
        id: entity.__transient__[:record] && entity.__transient__[:record].guid || nil,
        deleted_at: entity.time_stamp.deleted_on || nil,
        description: content && content.body,
        image: media,
        image_identifier: image_identifier,
        small_image: media_thumb,
        blur_hash: blur_hash,
        formatted_address: nil, # can import from place if populated.
        event_start_date: entity.event_start_date,
        event_end_date: entity.event_end_date,
        event_start_time: entity.event_start_time,
        event_end_time: entity.event_end_time,
        latitude: lat,
        longitude: lng,
        user_id: user,
        inserted_at: entity.time_stamp.created_on,
        updated_at: entity.time_stamp.modified_on,
      }

      case Data.Repo.upsert(record) do
        {:ok, user_event} ->
          Jetzy.TanbitsResolution.Repo.insert_guid(Noizu.ERP.ref(entity), Data.Schema.UserEvent, user_event.id, context, options)


          with {:ok, room} <- Data.Context.create(Data.Schema.Room, %{room_type: "event_comments"}),
               {:ok, _room_users} <- Data.Context.create(Data.Schema.RoomUser, %{room_id: room.id, user_id: user}),
               {:ok, group_chat_room} <- Data.Context.create(Data.Schema.Room, %{room_type: "event_chat"}),
               {:ok, _group_chat_room_users} <-
                 Data.Context.create(Data.Schema.RoomUser, %{room_id: group_chat_room.id, user_id: user}),
               {:ok, %Data.Schema.UserEvent{} = user_event} <-
                 Data.Context.update(Data.Schema.UserEvent, user_event, %{
                   room_id: room.id,
                   group_chat_room_id: group_chat_room.id
                 }),
               _user_chat <- Data.Context.UserEvents.get_room(group_chat_room.id) |> Map.put(:user_event, user_event) do


            Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.UserEvent, user_event.id, context, options)

            (with %{media: %{entities: entities}} <- content,
                  true <- is_list(entities) && length(entities) > 0
               do
               Enum.map(entities, fn(h) ->
                 {image_identifier, image, thumb, blur_hash} = Jetzy.Entity.Image.Entity.image_thumb_hash(h, context, options)
                 if image do
                   insert = %{
                     image: image,
                     small_image: thumb,
                     blur_hash: blur_hash,
                     image_identifier: image_identifier,
                     user_event_id: user_event.id,
                   }
                   with {:ok, uei} <- Data.Context.create(Data.Schema.UserEventImage, insert) do
                     Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(h), Data.Schema.UserEventImage, uei.id, context, options)
                   end
                 end
               end)
             else
               _ -> nil
             end)

           # insert interests

           # TODO Tagging
#            if Map.has_key?(params, "post_tags") do send_push_notification_for_post_tagging(params["post_tags"], user_event.id, first_name <> last_name, user_id) end
#            reward_id = "46f0b6c5-0d3b-4bff-ab23-ec8ffba88b36"
#            push_notification_params_while_creating = %{"keys" => %{date: param["event_start_date"]},
#              "event" => "events_by_me", "user_id" => user_id, "sender_id" => user_id, "type" => "events_by_me", "resource_id" => user_event.id}
#            ApiWeb.Utils.PushNotification.send_push_notification(push_notification_params_while_creating)
#            ApiWeb.Api.V1_0.UserChatController.broadcast_to_chat_listing(user_id, room)
#            ApiWeb.Api.V1_0.UserChatController.broadcast_to_chat_listing(user_id, group_chat_room)
#            ApiWeb.Utils.Common.update_points(user_id, reward_id,20, "Created an event")
            # Jetzy.Module.Telemetry.Analytics.post_created(conn, user_id, user_event)
            entity
          else
           _error ->
              Data.Context.delete(user_event)
              entity
          end
      end
    end
    def layer_create!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end


    #----------------------------
    # layer_create
    #----------------------------
    def layer_update(%{__struct__: PersistenceLayer, schema: Data.Repo} = layer, entity, context, options) do
      layer_update!(layer, entity, context, options)
      entity
    end
    def layer_update(layer, entity, context, options) do
      super(layer, entity, context, options)
    end

    #----------------------------
    # layer_create
    #----------------------------
    def layer_update!(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do
      existing = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.UserEvent, Noizu.ERP.ref(entity), context, options) |> Noizu.ERP.entity!()
      content = Noizu.ERP.entity!(entity.content)
      {lng,lat} = case entity.geo do
                    %{coordinates: {lat, lng}} -> {lng, lat}
                    _ -> {nil, nil}
                  end
      user = Jetzy.User.Guid.Lookup.Repo.by_user!(entity.owner, context) || existing && existing.user_id
      {image_identifier, media, media_thumb, blur_hash} = (with %{media: %{entities: [h|_]}} <- content do
                                           Jetzy.Entity.Image.Entity.image_thumb_hash(h, context, options)
                                         else
                                           _ ->
                                             cond do
                                               existing -> {existing.image_identifier, existing.image, existing.small_image, existing.blur_hash}
                                               :else -> {nil, nil, nil, nil}
                                             end
                                         end)

      record = %Data.Schema.UserEvent{(existing || struct(Data.Schema.UserEvent,[])) |
        id: existing && existing.id || nil,
        deleted_at: entity.time_stamp.deleted_on || nil,
        description: content && content.body,
        image: media,
        image_identifier: image_identifier,
        small_image: media_thumb,
        blur_hash: blur_hash,
        event_start_date: entity.event_start_date,
        event_end_date: entity.event_end_date,
        event_start_time: entity.event_start_time,
        event_end_time: entity.event_end_time,
        latitude: lat,
        longitude: lng,
        user_id: user,
        inserted_at: entity.time_stamp.created_on,
        updated_at: entity.time_stamp.modified_on,
      }

      if !existing do
        Data.Repo.upsert(record)
        Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.UserEvent, existing.id, context, options)
      else
        Data.Repo.update(Data.Schema.UserEvent.changeset(record))
      end

      #
      (with %{media: %{entities: entities}} <- content,
            true <- is_list(entities) && length(entities) > 0
         do
         Enum.map(entities, fn(h) ->
           existing_uei = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.UserEventImage, Noizu.ERP.ref(h), context, options) |> Noizu.ERP.entity!()
           {image_identifier, media, media_thumb, blur_hash} = Jetzy.Entity.Image.Entity.image_thumb_hash(h, context, options)
           insert = %{
             image_identifier: image_identifier,
             image: media,
             small_image: media_thumb,
             blur_hash: blur_hash,
             user_event_id: record.id,
           }
           cond do
             existing_uei ->
               Data.Context.update(Data.Schema.UserEventImage, existing_uei, insert)
             :else ->
               with {:ok, uei} <- Data.Context.create(Data.Schema.UserEventImage, insert) do
                 Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(h), Data.Schema.UserEventImage, uei.id, context, options)
               end
           end
         end)
       else
         _ -> nil
       end)
      entity
    end
    def layer_update!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end

    #----------------------------
    # layer_create_callback
    #----------------------------
    def layer_create_callback(%{__struct__: PersistenceLayer, schema: JetzySchema.Database} = layer, entity, context, options), do: layer_create_callback!(layer, entity, context, options)
    def layer_create_callback(layer, entity, context, options), do: super(layer, entity, context, options)
    def layer_create_callback!(%{__struct__: PersistenceLayer, schema: JetzySchema.Database} = layer, entity, context, options) do
      if (entity.__transient__[:record]) do
        le = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Post.Table, entity.__transient__.record.id, context, options)
        cond do
          le == nil -> Jetzy.LegacyResolution.Repo.insert_identifier_and_guid!(Noizu.ERP.ref(entity), JetzySchema.MSSQL.Post.Table, entity.__transient__.record.id, entity.__transient__.record.guid, context, options)
          Noizu.ERP.entity!(le) -> :skip
          :else ->
            # this is unexpected.
            Logger.warn("#{__MODULE__}.create overriding legacy resolution entry")
            Jetzy.LegacyResolution.Repo.update_identifier_and_guid!(Noizu.ERP.ref(entity), JetzySchema.MSSQL.Post.Table, entity.__transient__.record.id, entity.__transient__.record.guid, context, options)
        end
      end

      entity = case entity.interests do
                 %Jetzy.Post.Interest.Repo{entities: entities} ->
                   entities = Enum.map(entities, fn(entity) ->
                     case entity do
                       %JetzySchema.MSSQL.Post.Interest.Table{} ->
                         Jetzy.Post.Interest.Repo.by_legacy!(entity.id, context, options)
                       %Jetzy.Post.Interest.Entity{} -> entity
                       _ -> nil
                     end
                   end) |> Enum.filter(&(&1))
                   entities = Enum.filter(entities, &(&1))
                   entity
                   |> put_in([Access.key(:interests), Access.key(:entities)], entities)
                   |> update_in([Access.key(:interests), Access.key(:__transient__)], &(&1 && put_in(&1, [:partials], false)))
                 _ -> entity
               end
      super(layer, entity, context, options)
    end
    def layer_create_callback!(layer, entity, context, options), do: super(layer, entity, context, options)



    #------------------------------------
    #
    #------------------------------------
    def by_legacy(identifier, context, options) when is_integer(identifier) do
      Jetzy.LegacyResolution.Repo.by_legacy(JetzySchema.MSSQL.Post.Table, identifier, context, options)
    end

    #------------------------------------
    #
    #------------------------------------
    def by_legacy!(identifier, context, options) when is_integer(identifier) do
      Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Post.Table, identifier, context, options)
    end


    #------------------------------------
    #
    #------------------------------------
    def by_legacy_guid(identifier, context, options) when is_bitstring(identifier) do
      Jetzy.LegacyResolution.Repo.by_legacy_guid(JetzySchema.MSSQL.Post.Table, identifier, context, options)
    end

    #------------------------------------
    #
    #------------------------------------
    def by_legacy_guid!(identifier, context, options) when is_bitstring(identifier) do
      Jetzy.LegacyResolution.Repo.by_legacy_guid!(JetzySchema.MSSQL.Post.Table, identifier, context, options)
    end


    #------------------------------------
    # import!
    #------------------------------------
    def import!(identifier, context, options \\ nil)
    def import!(_identifier, context, _options) when not is_system_caller(context), do: {:error, :permission_denied}
    def import!(identifier, context, options) when is_integer(identifier) do
      cond do
        record = JetzySchema.MSSQL.Post.Table.by_identifier!(identifier, context, options) -> import!(record, context, options)
        :else -> {:error, :not_found}
      end
    end
    def import!(guid, context, options) when is_bitstring(guid) do
      cond do
        record = JetzySchema.MSSQL.Post.Table.by_guid!(guid, context, options) -> import!(record, context, options)
        :else -> {:error, :not_found}
      end
    end
    def import!(%{__struct__: JetzySchema.MSSQL.Post.Table} = record, context, options) do
      #now = options[:current_time] || DateTime.utc_now()
      load = %{}

      # Existing Record
      existing_entity = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Post.Table, record.id, context, options)
      existing_entity = existing_entity && (Jetzy.Post.Repo.get!(Noizu.ERP.id(existing_entity), context, [load: load]) || throw "Unable to continue, missing record #{inspect existing_entity}")

      # Load
      options_b = (options || [])
                  |> put_in([:existing], existing_entity || false)
                  |> put_in([:load], load)
      options[:verbose] && Logger.info "IMPORTING post #{inspect record.id}"
      cond do
        existing_entity && !options[:refresh] -> {:error, :already_imported}
        entity = Jetzy.Post.Entity.__from_record__(Jetzy.Post.Repo.__persistence__().schemas[JetzySchema.MSSQL.Repo], record, context, options_b) ->
          cond do
            existing_entity ->
              # @todo scan for changes - profile image, credentials, etc.
              update!(entity, context)
              {:error, {:refreshed, :not_yet_implemented}}
            :else ->
              options_c = (options[:create] || [])
                          |> put_in([:persist], [])
              imported_entity = create!(entity, context, options_c)
              if imported_entity do
                # !existing_entity && Jetzy.LegacyResolution.Repo.insert_identifier_and_guid!(Noizu.ERP.ref(imported_entity), JetzySchema.MSSQL.Post.Table, record.id, record.guid, context, options)

                # Import Comments
                i_ref = Noizu.ERP.ref(imported_entity)
                options_a = (options || [])
                            |> put_in([:parent], i_ref)
                            |> put_in([:post], i_ref)
                (JetzySchema.MSSQL.Post.Table.comments(record, context, options_a) || [])
                |> Enum.map(&(Jetzy.Comment.Repo.import!(&1, context, options_a)))

                # Import Interactions
                options_b = put_in(options || [], [:subject], Noizu.ERP.ref(imported_entity))
                (JetzySchema.MSSQL.Post.Table.reactions(record, context, options_b) || [])
                |> Enum.map(&(Jetzy.Entity.Subject.Reaction.Repo.import!(&1, context, options_b)))
                Jetzy.Entity.Interactions.Repo.rebuild!(imported_entity, context, options)

              end
              imported_entity && {:imported, imported_entity} || {:error, :create_failed}

              # @todo - import interactions and comments
              {:imported, imported_entity}
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
    end




    def import!(ref, _context, _options) do
      {:error, {:invalid_record, ref}}
    end


    #-----------------
    # list
    #-------------------
    def list(pagination, filter, _context, _options) do
      # @todo generic logic to query mnesia or ecto, including pagination
      entities = JetzySchema.Database.Post.Table.match!([])
                 |> Amnesia.Selection.values()
                 |> Enum.map(&(&1.entity))
      struct(Jetzy.Post.Repo, [pagination: pagination, filter: filter, entities: entities, length: length(entities), retrieved_on: DateTime.utc_now()])
    end

    #-----------------
    # list!
    #-------------------
    def list!(pagination, filter, _context, _options) do
      # @todo generic logic to query mnesia or ecto, including pagination
      entities = JetzySchema.Database.Post.Table.match!([])
                 |> Amnesia.Selection.values()
                 |> Enum.map(&(&1.entity))
      struct(Jetzy.Post.Repo, [pagination: pagination, filter: filter, entities: entities, length: length(entities), retrieved_on: DateTime.utc_now()])
    end

    #===-------
    # has_permission?
    #===-------
    def has_permission?(_, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_, %Noizu.ElixirCore.CallingContext{}, _options), do: true
    def has_permission?(_repo, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_repo, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

    #===-------
    # has_permission!
    #===-------
    def has_permission!(_, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_, %Noizu.ElixirCore.CallingContext{}, _options), do: true
    def has_permission!(_repo, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_repo, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true


  end
end
