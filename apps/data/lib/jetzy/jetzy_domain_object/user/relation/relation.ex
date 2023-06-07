#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Relation do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "user-relation"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  # @persistence_layer {Data.Repo, Data.Schema.User, [cascade?: true, sync: false, fallback?: false, cascade_block?: true]}
  #@index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]]}
  # Pending Implementation: @index {Jetzy.Admin.Index, pii: :level_0, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]}
  defmodule Entity do
    @nmid_index 333
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      public_field :user
      public_field :relation

      public_field :friend
      public_field :friend_status

      public_field :follow
      public_field :follow_status
      public_field :followed
      public_field :followed_status

      public_field :mute
      public_field :mute_status
      public_field :muted
      public_field :muted_status

      public_field :block
      public_field :block_status
      public_field :blocked
      public_field :blocked_status

      public_field :relative
      public_field :relative_status
      public_field :relative_type

      public_field :relationship
      public_field :relationship_status
      public_field :relationship_type

      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
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
    Noizu.DomainObject.noizu_repo do
    end


    #----------------------------
    # layer_create
    #----------------------------
    def layer_create(%{__struct__: PersistenceLayer, schema: Data.Repo} = layer, entity, context, options) do
      layer_create!(layer, entity, context, options)
    end
    def layer_create(%{__struct__: PersistenceLayer, schema: JetzySchema.Database} = layer, entity, context, options) do
      entity = super(layer, entity, context, options)
      if (entity.meta[:legacy_identifier]) do
        Jetzy.LegacyResolution.Repo.insert(Noizu.ERP.ref(entity), JetzySchema.MSSQL.User.Friend.Table, entity.meta[:legacy_identifier], context, options )
      end
      entity
    end
    def layer_create(layer, entity, context, options) do
      super(layer, entity, context, options)
    end


    #----------------------------
    # layer_create
    #----------------------------
#    def layer_create!(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do
#      user = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.User, Noizu.ERP.ref(entity.user), context, options) |> Noizu.ERP.id()
#      relation = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.User, Noizu.ERP.ref(entity.relation), context, options)  |> Noizu.ERP.id()
#      friend_blocked = entity.block_status == :active
#      is_blocked = entity.blocked_status == :active
#      is_friend = entity.friend_status == :active
#
#      friend = entity.friend && Noizu.ERP.entity!(entity.friend)
#      ufr = friend && Noizu.ERP.entity!(friend.user_friend_request)
#      is_request_sent = cond do
#                          ufr && ufr.status in [:inactive, :pending] -> true
#                          :else -> false
#                        end
#
#      record = %{
#        user_id: user,
#        friend_id: relation,
#        friend_blocked: friend_blocked,
#        is_blocked: is_blocked,
#        is_friend: is_friend,
#        is_request_sent: is_request_sent,
#        deleted_at: entity.time_stamp.deleted_on || nil,
#        created_at: entity.time_stamp.created_on,
#        updated_at: entity.time_stamp.modified_on,
#      }
#      {:ok, insert} = Data.Context.create(Data.Schema.UserFriend, record)
#      Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.UserFriend, insert.id, context, options)
#      entity
#    end
    def layer_create!(%{__struct__: PersistenceLayer, schema: JetzySchema.Database} = layer, entity, context, options) do
      entity = super(layer, entity, context, options)
      if (entity.meta[:legacy_identifier]) do
        Jetzy.LegacyResolution.Repo.insert!(Noizu.ERP.ref(entity), JetzySchema.MSSQL.User.Friend.Table, entity.meta[:legacy_identifier], context, options )
      end
      entity
    end
    def layer_create!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end



    #----------------------------
    # layer_update
    #----------------------------
#    def layer_update(%{__struct__: PersistenceLayer, schema: Data.Repo} = layer, entity, context, options) do
#      layer_update!(layer, entity, context, options)
#    end
    def layer_update(layer, entity, context, options) do
      super(layer, entity, context, options)
    end

#
#    #----------------------------
#    # layer_create
#    #----------------------------
#    def layer_update!(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do
#      existing = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.UserFriend, Noizu.ERP.ref(entity), context, options) |> Noizu.ERP.entity!
#      user = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.User, Noizu.ERP.ref(entity.user), context, options) |> Noizu.ERP.id()
#      relation = Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.User, Noizu.ERP.ref(entity.relation), context, options)  |> Noizu.ERP.id()
#      friend_blocked = entity.block_status == :active
#      is_blocked = entity.blocked_status == :active
#      is_friend = entity.friend_status == :active
#
#      friend = entity.friend && Noizu.ERP.entity!(entity.friend)
#      ufr = friend && Noizu.ERP.entity!(friend.user_friend_request)
#      is_request_sent = cond do
#                          ufr && ufr.status in [:inactive, :pending] -> true
#                          :else -> false
#                        end
#
#      record = %{
#        user_id: user,
#        friend_id: relation,
#        friend_blocked: friend_blocked,
#        is_blocked: is_blocked,
#        is_friend: is_friend,
#        is_request_sent: is_request_sent,
#        deleted_at: entity.time_stamp.deleted_on || nil,
#        created_at: entity.time_stamp.created_on,
#        updated_at: entity.time_stamp.modified_on,
#      }
#      cond do
#        existing ->
#          {:ok, _} = Data.Context.update(Data.Schema.UserFriend, existing, record)
#        :else ->
#          {:ok, insert} = Data.Context.create(Data.Schema.UserFriend, record)
#          Jetzy.TanbitsResolution.Repo.insert_guid!(Noizu.ERP.ref(entity), Data.Schema.UserFriend, insert.id, context, options)
#      end
#      entity
#    end
    def layer_update!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end

    def by_user(user, relation, _context, _options) do
      [user: Noizu.ERP.ref(user), relation: Noizu.ERP.ref(relation)]
      |> JetzySchema.Database.User.Relation.Table.match!()
      |> Amnesia.Selection.values()
      |> case do
           [h|_] -> h.entity
           _ -> nil
         end
    end

    def rebuild(existing, context, options) do
        block = Jetzy.User.Block.Repo.by_user(existing.user, existing.relation, context, options)
        blocked = Jetzy.User.Block.Repo.by_user(existing.relation, existing.user, context, options)
        friend = Jetzy.User.Friend.Repo.by_user(existing.user, existing.relation, context, options)
        follow = Jetzy.User.Follow.Repo.by_user(existing.user, existing.relation, context, options)
        %Jetzy.User.Relation.Entity{existing|
          block: block && Noizu.ERP.ref(block),
          block_status: block && block.status,
          blocked: blocked && Noizu.ERP.ref(blocked),
          blocked_status: blocked && blocked.status,
          friend: friend && Noizu.ERP.ref(friend),
          friend_status: friend && friend.status,
          follow: follow && Noizu.ERP.ref(follow),
          follow_status: follow && follow.status,
        }
    end


    def update__block!(user_a, user_b, record, context, options) do
      reason = %{title: "Auto Generate", body: "Imported"}
      cond do
        record.friend_blocked ->
          block_ab = Jetzy.User.Block.Repo.by_user(user_a, user_b, context, options) || %Jetzy.User.Block.Entity{user: user_a, block: user_b, reason: reason, status: :active, blocked_on: record.created_on && DateTime.truncate(record.created_on, :second), time_stamp: JetzySchema.MSSQL.User.Friend.Table.time_stamp!(record, context, options), meta: [legacy_identifier: record.id]}
          cond do
            block_ab.identifier -> Jetzy.User.Block.Repo.update!(block_ab, context, options)
            :else -> Jetzy.User.Block.Repo.create!(block_ab, context, options)
          end
        :else -> :nop
      end
      cond do
        record.is_blocked ->
          block_ba = Jetzy.User.Block.Repo.by_user(user_b, user_a, context, options) || %Jetzy.User.Block.Entity{user: user_b, block: user_a, reason: reason, status: :active, blocked_on: record.created_on && DateTime.truncate(record.created_on, :second), time_stamp: JetzySchema.MSSQL.User.Friend.Table.time_stamp!(record, context, options), meta: [legacy_identifier: record.id]}
          cond do
            block_ba.identifier -> Jetzy.User.Block.Repo.update!(block_ba, context, options)
            :else -> Jetzy.User.Block.Repo.create!(block_ba, context, options)
          end
        :else -> :nop
      end
    end

    def update__follow!(user_a, user_b, record, context, options) do
      cond do
        record.is_friend ->
          follow_ab = Jetzy.User.Follow.Repo.by_user(user_a, user_b, context, options) || %Jetzy.User.Follow.Entity{user: user_a, follow: user_b, status: :active, followed_on: record.created_on && DateTime.truncate(record.created_on, :second), time_stamp: JetzySchema.MSSQL.User.Friend.Table.time_stamp!(record, context, options), meta: [legacy_identifier: record.id]}
          follow_ba = Jetzy.User.Follow.Repo.by_user(user_b, user_a, context, options) || %Jetzy.User.Follow.Entity{user: user_b, follow: user_a, status: :active, followed_on: record.created_on && DateTime.truncate(record.created_on, :second), time_stamp: JetzySchema.MSSQL.User.Friend.Table.time_stamp!(record, context, options), meta: [legacy_identifier: record.id]}
          cond do
            follow_ab.identifier -> Jetzy.User.Follow.Repo.update!(follow_ab, context, options)
            :else -> Jetzy.User.Follow.Repo.create!(follow_ab, context, options)
          end
          cond do
            follow_ba.identifier -> Jetzy.User.Follow.Repo.update!(follow_ba, context, options)
            :else -> Jetzy.User.Follow.Repo.create!(follow_ba, context, options)
          end
        record.is_request_sent ->
          follow_ab = Jetzy.User.Follow.Repo.by_user(user_a, user_b, context, options) || %Jetzy.User.Follow.Entity{user: user_a, follow: user_b, status: :active, followed_on: record.created_on && DateTime.truncate(record.created_on, :second), time_stamp: JetzySchema.MSSQL.User.Friend.Table.time_stamp!(record, context, options), meta: [legacy_identifier: record.id]}
          cond do
            follow_ab.identifier -> Jetzy.User.Follow.Repo.update!(follow_ab, context, options)
            :else -> Jetzy.User.Follow.Repo.create!(follow_ab, context, options)
          end
        :else -> :nop # do nothing.
      end
    end

    def import!(%JetzySchema.MSSQL.User.Friend.Table{} = record, context, options) do
      # Load Existing
      user_a = options[:user_a] || Jetzy.User.Repo.by_guid!(record.user_id, context)
      user_b = options[:user_b] || Jetzy.User.Repo.by_guid!(record.friend_id, context)
      cond do
        !user_a -> {:error, :user_not_found}
        !user_b -> {:error, :friend_not_found}
        existing = Jetzy.LegacyResolution.Repo.by_type_and_legacy!(Jetzy.User.Relation.Entity, JetzySchema.MSSQL.User.Friend.Table, record.id, context, options) -> {:error, {:existing, record.id}}
        :else ->
          entity = by_user(user_a, user_b, context, options) || %Jetzy.User.Relation.Entity{user: user_a, relation: user_b}
          update__block!(user_a, user_b, record, context, options)
          update__follow!(user_a, user_b, record, context, options)
          entity = rebuild(entity, context, options) |> put_in([Access.key(:meta), :legacy_identifier], record.id)
          relations = cond do
                        entity.identifier -> update!(entity, context, options)
                        :else -> update = create!(entity, context, options)
                      end
          {:imported, {record.id, relations}}
      end
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
