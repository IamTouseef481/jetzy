#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Interest do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "interest"
  @persistence_layer {:mnesia, cascade?: true, cascade_block?: true}
  @persistence_layer {:ecto, cascade?: true, cascade_block?: true}
  @persistence_layer {Data.Repo, Data.Schema.Interest, [cascade?: true, sync: false, fallback?: false, cascade_block?: true]}
  @persistence_layer JetzySchema.MSSQL.Repo

  #========================================================================================================================
  # Jetzy.Interest.Entity
  #========================================================================================================================
  defmodule Entity do
    @nmid_index 95
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :owner
      public_field :public
      public_field :private_group
      public_field :visibility
      public_field :color
      public_field :status
      public_field :slug
      public_field :interest_image, nil, Jetzy.Entity.Image.TypeHandler
      public_field :description, nil, Jetzy.VersionedString.TypeHandler
      public_field :details, nil, Jetzy.CMS.Article.Detail.TypeHandler
      internal_field :moderation, nil, type: Jetzy.ModerationDetails.TypeHandler
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end

    #----------------------------
    # __from_record__
    #----------------------------
    def __from_record__(layer, record, context, options \\ nil)
    def __from_record__(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, %{__struct__: Data.Schema.Interest} = _record, _context, _options), do: nil
    def __from_record__(%{__struct__: PersistenceLayer, schema: JetzySchema.MSSQL.Repo} = _layer, %{__struct__: JetzySchema.MSSQL.Interest.Table} = record, context, options) do
      existing = cond do
                   options[:existing] -> options[:existing]
                   existing_entity = Jetzy.LegacyResolution.Repo.by_type_and_legacy!(Jetzy.Interest.Entity, JetzySchema.MSSQL.Interest.Table, record.id, context, options) ->
                     Noizu.ERP.entity!(existing_entity)
                   :else -> nil
                 end
      owner = options[:organization] || (existing && existing.owner) || context.caller
      # CMS & Versioned String
      time_stamp =  JetzySchema.MSSQL.Interest.Table.time_stamp(record, context, options)
      description = (cond do
                       existing && existing.description -> %{existing.description| title: (record.interest_name || ""), body: (record.description || ""), modified_on: time_stamp.modified_on, editor: owner}
                       :else -> %{title: (record.interest_name || ""), body: (record.description || ""), editor: owner}
                     end)
      _media = nil # v.image_name
      content = Jetzy.CMS.Article.Detail.TypeHandler.sync(existing && existing.content, %{title: record.interest_name, body: record.description, editor: owner, time_stamp: time_stamp}, context, options)

      uri = JetzySchema.MSSQL.Interest.Table.interest_image(record, context, options)
      interest_image = uri && {:import, {:interest, uri}}

      %Jetzy.Interest.Entity{(existing || %Jetzy.Interest.Entity{})|
        owner: owner,
        public: !record.private,
        private_group: record.private_group,
        visibility: (!record.private) && :public || :private,
        color: String.trim_leading(record.back_ground_color || "", "#"),
        status: record.status && :active || :pending,
        description: description,
        details: content,
        interest_image: interest_image,
        moderation: existing && existing.moderation || Jetzy.ModerationDetails.__struct__([]),
        time_stamp: time_stamp, # Noizu.DomainObject.TimeStamp.Second.import(record.created_on, record.modified_on, record.deleted && record.modified_on || nil, :microsecond)
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


  end # end Entity

  #========================================================================================================================
  # Jetzy.Interest.Repo
  #========================================================================================================================
  defmodule Repo do
    require Jetzy.ElixirScaffolding
    Jetzy.ElixirScaffolding.jetzy_repo do
    end

    #----------------------------
    # layer_create
    #----------------------------
    def layer_create(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do
      {name, description} = case Noizu.ERP.entity(entity.description) do
                              %{title: title, body: body} -> {title, body}
                              _ -> {nil, nil}
                            end
      {image_identifier, image_name, thumb_name, blur_hash} = Jetzy.Entity.Image.Entity.image_thumb_hash(entity.interest_image, context, options)
      record = %{
                 deleted_at: entity.time_stamp.deleted_on,
                 background_colour: entity.color,
                 description: description,
                 image_identiifer: image_identifier,
                 image_name: image_name,
                 small_image_name: thumb_name,
                 blur_hash: blur_hash,
                 interest_name: name,
                 is_deleted:  entity.time_stamp.deleted_on && true || false,
                 is_group_private: !entity.public,
                 is_private: entity.visibility == :private,
                 status: entity.status == :active,
                 # created_by_id: Noizu.ERP.id(entity.owner)
               }
      with {:ok, insert} <- Data.Context.create(Data.Schema.Interest, record) do
        Jetzy.TanbitsResolution.Repo.insert_guid(Noizu.ERP.ref(entity), Data.Schema.Interest, insert.id, context, options)
      end

      entity
    end
    def layer_create(layer, entity, context, options) do
      super(layer, entity, context, options)
    end

    #----------------------------
    # layer_create!
    #----------------------------
    def layer_create!(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do
      {name, description} = case Noizu.ERP.entity!(entity.description) do
                            %{title: title, body: body} ->
                              title = case title do
                                        %{markdown: v} -> v
                                        v -> v
                                      end
                              body = case body do
                                        %{markdown: v} -> v
                                        v -> v
                                      end
                              {title, body}
                            _ -> {nil, nil}
                            end

#      created_by = case Noizu.ERP.id(entity.owner) do
#                     v when is_bitstring(v) -> v
#                     :admin -> nil
#                   end
      {image_identifier, image_name, thumb_name, blur_hash} = Jetzy.Entity.Image.Entity.image_thumb_hash(entity.interest_image, context, options)

      record = %{
        deleted_at: entity.time_stamp.deleted_on,
        background_colour: entity.color,
        description: description,
        image_name: image_name,
        image_identifier: image_identifier,
        small_image_name: thumb_name,
        blur_hash: blur_hash,
        interest_name: name,
        is_deleted:  entity.time_stamp.deleted_on && true || false,
        is_group_private: !entity.public,
        is_private: entity.visibility == :private,
        status: entity.status == :active,
        # created_by_id: Noizu.ERP.id(entity.owner)
      }
      with {:ok, insert} <- Data.Context.create(Data.Schema.Interest, record) do
        Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.Interest, insert.id, context, options)
      end
      entity
    end
    def layer_create!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end


    #----------------------------
    # layer_update
    #----------------------------
    def layer_update(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do
      existing = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.Interest, Noizu.ERP.ref(entity), context, options) |> Noizu.ERP.entity()

      {name, description} = case Noizu.ERP.entity(entity.description) do
                              %{title: title, body: body} -> {title, body}
                              _ -> {nil, nil}
                            end

      {image_identifier, image_name, thumb_name, blur_hash} = Jetzy.Entity.Image.Entity.image_thumb_hash(entity.interest_image, context, options)

      record = %{
        deleted_at: entity.time_stamp.deleted_on,
        background_colour: entity.color,
        description: description,
        image_name: image_name,
        image_identifier: image_identifier,
        small_image_name: thumb_name,
        blur_hash: blur_hash,
        interest_name: name,
        is_deleted:  entity.time_stamp.deleted_on && true || false,
        is_group_private: entity.private_group,
        is_private: entity.visibility == :private,
        status: entity.status == :active,
        created_by_id: Noizu.ERP.id(entity.owner)
      }

      cond do
        existing ->
          Data.Context.update(Data.Schema.Interest, existing, record)
        :else ->
          {:ok, insert} = Data.Context.create(Data.Schema.Interest, record)
          Jetzy.TanbitsResolution.Repo.insert_guid(Noizu.ERP.ref(entity), Data.Schema.Interest, insert.id, context, options)
      end

      entity
    end
    def layer_update(layer, entity, context, options) do
      super(layer, entity, context, options)
    end


    #----------------------------
    # layer_update
    #----------------------------
    def layer_update!(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do
      existing = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.Interest, Noizu.ERP.ref(entity), context, options) |> Noizu.ERP.entity!()

      {name, description} = case Noizu.ERP.entity!(entity.description) do
                              %{title: title, body: body} -> {title, body}
                              _ -> {nil, nil}
                            end

      {image_identifier, image_name, thumb_name, blur_hash} = Jetzy.Entity.Image.Entity.image_thumb_hash(entity.interest_image, context, options)

      record = %{
        deleted_at: entity.time_stamp.deleted_on,
        background_colour: entity.color,
        description: description,
        image_name: image_name,
        image_identifier: image_identifier,
        small_image_name: thumb_name,
        blur_hash: blur_hash,
        interest_name: name,
        is_deleted:  entity.time_stamp.deleted_on && true || false,
        is_group_private: entity.private_group,
        is_private: entity.visibility == :private,
        status: entity.status == :active,
        created_by_id: Noizu.ERP.id(entity.owner)
      }

      cond do
        existing ->
          Data.Context.update(Data.Schema.Interest, existing, record)
        :else ->
          {:ok, insert} = Data.Context.create(Data.Schema.Interest, record)
          Jetzy.TanbitsResolution.Repo.insert_guid(Noizu.ERP.ref(entity), Data.Schema.Interest, insert.id, context, options)
      end

      entity
    end
    def layer_update!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end


    #------------------------------------
    # by_legacy
    #------------------------------------
    def by_legacy(identifier, context, options) do
      case Jetzy.LegacyResolution.Repo.by_type_and_legacy(Jetzy.Interest.Entity, JetzySchema.MSSQL.Interest.Table, identifier, context, options) do
        nil ->
          case import!(identifier, context, options) do
            {:imported, entity} -> entity
            {:refreshed, entity} -> entity
            _ -> nil
          end
        v -> v
      end
    end
    #------------------------------------
    # by_legacy!
    #------------------------------------
    def by_legacy!(identifier, context, options) do
      case Jetzy.LegacyResolution.Repo.by_type_and_legacy!(Jetzy.Interest.Entity, JetzySchema.MSSQL.Interest.Table, identifier, context, options) do
        nil ->
          case import!(identifier, context, options) do
            {:imported, entity} -> entity
            {:refreshed, entity} -> entity
            _ -> nil
          end
        v -> v
      end
    end

    #------------------------------------
    # import!
    #------------------------------------
    def import!(legacy_identifier, context, options \\ nil)
    def import!(_ref, context, _options) when not is_system_caller(context), do: {:error, :permission_denied}
    def import!(legacy_identifier, context, options) when is_integer(legacy_identifier) do
      JetzySchema.MSSQL.Repo.get(JetzySchema.MSSQL.Interest.Table, legacy_identifier)
      |> import!(context, options)
    end
    def import!(%{__struct__: JetzySchema.MSSQL.Interest.Table} = record, context, options) do
      existing_entity = Jetzy.LegacyResolution.Repo.by_type_and_legacy!(Jetzy.Interest.Entity, JetzySchema.MSSQL.Interest.Table, record.id, context, options)
      existing_entity = existing_entity && Noizu.ERP.entity!(existing_entity)

      options_b = put_in(options || [], [:existing], existing_entity || false)
      cond do
        existing_entity && !options[:refresh] -> {:error, :already_imported}
        entity = Jetzy.Interest.Entity.__from_record__(__persistence__().schemas[JetzySchema.MSSQL.Repo], record, context, options_b) ->
          cond do
            entity == existing_entity -> {:unchanged, existing_entity}
            existing_entity ->
              entity = update!(entity, context, options[:update])
              options_c = put_in(options || [], [:interest], entity)
              Jetzy.Group.Repo.import!(record, context, options_c)
              {:refreshed, entity}
            imported_entity = create!(entity, context, options[:create]) ->
              Jetzy.LegacyResolution.Repo.insert!(imported_entity, JetzySchema.MSSQL.Interest.Table, record.id, context)
              options_c = put_in(options || [], [:interest], imported_entity)
              Jetzy.Group.Repo.import!(record, context, options_c)
              {:imported, imported_entity}
          end
      end
    end
    def import!(ref, _context, _options) do
      {:error, {:invalid_record, ref}}
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
  end # end Repo
end
