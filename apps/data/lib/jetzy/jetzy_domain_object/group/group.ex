#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Group do

  use Noizu.DomainObject
  @vsn 1.0
  @sref "group"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  @persistence_layer {JetzySchema.MSSQL.Repo,  [cascade?: false, sync: false]}
  defmodule Entity do
    @nmid_index 93
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      @index true
      public_field :visibility
      public_field :sharing, nil, Jetzy.Entity.Share.Repo.TypeHandler
      public_field :details, nil, Jetzy.VersionedString.TypeHandler
      public_field :description, nil, Jetzy.CMS.Article.Detail.TypeHandler
      public_field :status
      public_field :moderation, nil, Jetzy.ModerationDetails.TypeHandler
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end

    #----------------------------
    # __from_record__
    #----------------------------
    def __from_record__(layer, record, context, options \\ nil)
    def __from_record__(%{__struct__: PersistenceLayer, schema: JetzySchema.MSSQL.Repo} = _layer, %{__struct__: JetzySchema.MSSQL.Interest.Table, private_group: false} = _record, _context, _options), do: nil
    def __from_record__(%{__struct__: PersistenceLayer, schema: JetzySchema.MSSQL.Repo} = _layer, %{__struct__: JetzySchema.MSSQL.Interest.Table, private_group: true} = record, context, options) do
      existing = cond do
                   options[:existing] == false -> nil
                   is_struct(options[:existing]) -> options[:existing]
                   ref = Jetzy.LegacyResolution.Repo.by_type_and_legacy(
                     Jetzy.Group.Entity,
                     JetzySchema.MSSQL.Interest.Table,
                     record.id,
                     context,
                     options) -> Noizu.ERP.entity(ref)
                   :else -> nil
                 end
      owner = options[:organization] || (existing && existing.owner) || context.caller
      time_stamp =  JetzySchema.MSSQL.Interest.Table.time_stamp(record, context, options)

      # Visibility of the group itself, additional permission scheme will be needed to control inspecting members, etc. and related permissions.
      {visibility, sharing} = cond do
                     existing -> {existing.visibility, existing.sharing}
                     record.private ->
                       visibility = :group
                       share = %Jetzy.Entity.Share.Repo{
                         entities: [
                           %Jetzy.Entity.Share.Entity{
                             status: :active,
                             subject: {:bind, fn(_partial, _context, options) -> options[:subject] end},
                             share_type: :group,
                             share_with:  {:bind, fn(_partial, _context, options) -> options[:subject] end},
                             time_stamp: time_stamp,
                             __transient__: %{late_binding: true}
                           }
                         ],
                         length: 1,
                       }
                       {visibility, share}
                     :else ->
                       visibility = :public
                       share = %Jetzy.Entity.Share.Repo{
                         entities: [], length: 0,
                       }
                       {visibility, share}
                   end



      # CMS & Versioned String
      description = (cond do
                       existing && existing.description -> %Jetzy.VersionedString.Entity{existing.description| title: (record.interest_name || ""), body: (record.description || ""), modified_on: time_stamp.modified_on, editor: owner}
                       :else -> %{title: (record.interest_name || ""), body: (record.description || ""), editor: owner}
                     end)
      #media = nil # v.image_name
      content = Jetzy.CMS.Article.Detail.TypeHandler.sync(existing && existing.content, %{title: record.interest_name, body: record.description, editor: owner, time_stamp: time_stamp}, context, options)



      %Jetzy.Group.Entity{(existing || %Jetzy.Group.Entity{})|
        visibility: visibility,
        sharing: sharing,
        status: record.status && :active || :pending,
        description: description,
        details: content,
        moderation: existing && existing.moderation || %Jetzy.ModerationDetails{},
        time_stamp: time_stamp
      }
    end
    def __from_record__(layer, record, context, options) do
      super(layer, record, context, options)
    end



  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end

    #------------------------------------
    # by_legacy
    #------------------------------------
    def by_legacy(identifier, context, options) do
      Jetzy.LegacyResolution.Repo.by_type_and_legacy(Jetzy.Group.Entity, JetzySchema.MSSQL.Interest.Table, identifier, context, options)
    end
    #------------------------------------
    # by_legacy!
    #------------------------------------
    def by_legacy!(identifier, context, options) do
      Jetzy.LegacyResolution.Repo.by_type_and_legacy!(Jetzy.Group.Entity, JetzySchema.MSSQL.Interest.Table, identifier, context, options)
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
    def import!(%{__struct__: JetzySchema.MSSQL.Interest.Table, private_group: false} = record, _context, _options) do
      {:error, {record.id, :non_group_interest}}
    end
    def import!(%{__struct__: JetzySchema.MSSQL.Interest.Table} = record, context, options) do
      existing_entity = by_legacy!(record.id, context, options)
      existing_entity = existing_entity && Noizu.ERP.entity!(existing_entity)

      options_b = put_in(options || [], [:existing], existing_entity || false)
      cond do
        existing_entity && !options[:refresh] -> {:error, :already_imported}
        entity = Jetzy.Group.Entity.__from_record__(__persistence__().schemas[JetzySchema.MSSQL.Repo], record, context, options_b) ->
          cond do
            entity == existing_entity -> {:unchanged, existing_entity}
            existing_entity ->
              entity = update!(entity, context, options[:update])
              {:refreshed, entity}
            imported_entity = create!(entity, context, options[:create]) ->
              Jetzy.LegacyResolution.Repo.insert!(Noizu.ERP.ref(imported_entity), JetzySchema.MSSQL.Interest.Table, record.id, context)
              {:imported, imported_entity}
          end
      end
    end
    def import!(ref, _context, _options) do
      {:error, {:invalid_record, ref}}
    end




  end




end
