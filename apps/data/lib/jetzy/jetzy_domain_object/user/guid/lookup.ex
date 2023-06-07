#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Guid.Lookup do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "user-lku-guid"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  @persistence_layer {:redis, cascade?: true}
  defmodule Entity do
    @nmid_index 120
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      @required {:ref, Jetzy.User.Entity}
      @pii :level_0
      restricted_field :user

      @pii :level_0
      @required true
      restricted_field :guid

      @enum Jetzy.Status
      @required true
      restricted_field :status
    end
  end

  defmodule Repo do
    require Logger
    import Ecto.Query, only: [from: 2]
    Noizu.DomainObject.noizu_repo do

    end



    def insert(user, guid, context, options \\ nil) when is_tuple(user) do
      context = Noizu.ElixirCore.CallingContext.system(context)
      Noizu.ERP.id(user) && %Jetzy.User.Guid.Lookup.Entity{
        user: user,
        guid: guid,
        status: :active,
      }
      |> create(context, options)
    end

    def insert!(user, guid, context, options \\ nil) when is_tuple(user) do
      context = Noizu.ElixirCore.CallingContext.system(context)
      Noizu.ERP.id(user) && %Jetzy.User.Guid.Lookup.Entity{
        user: user,
        guid: guid,
        status: :active,
      }
      |> create!(context, options) || Logger.error "UNABLE TO INSERT #{inspect user}"
    end



    #------------------------
    # by_user!
    #------------------------
    def by_user!(user, context, options \\ nil) do
      user = Noizu.ERP.ref(user)
      cond do
        ref = by_user__mnesia(user, context, options) -> ref
        ref = by_user__redis(user, context, options) -> ref
        ref = by_user__ecto(user, context, options) -> ref
        :else -> nil
      end
    end

    #------------------------
    # by_user__mnesia
    #------------------------
    def by_user__mnesia(user, _context, _options \\ nil) do
      case JetzySchema.Database.User.Guid.Lookup.Table.match!([user: user])
           |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.User.Guid.Lookup.Table} = entity | _] -> entity.guid
        _ -> nil
      end
    end

    #------------------------
    # by_user__redis
    #------------------------
    def by_user__redis(_user, _context, _options \\ nil) do
      nil
    end


    #------------------------
    # by_user__ecto
    #------------------------
    def by_user__ecto(user, _context, _options \\ nil) do
      query = from r in JetzySchema.PG.User.Guid.Lookup.Table,
                   where: r.user == ^user,
                   select: r,
                   limit: 1
      case JetzySchema.PG.Repo.all(query) do
        [resolution | _] -> resolution.guid
        _ -> nil
      end
    end

    #------------------------
    # by_guid!
    #------------------------
    def by_guid(guid, context, options \\ nil), do: by_guid!(guid, context, options)

    def by_guid!(guid, context, options \\ nil) do
      cond do
        ref = by_guid__mnesia(guid, context, options) -> ref
        ref = by_guid__redis(guid, context, options) -> ref
        ref = by_guid__ecto(guid, context, options) -> ref
        :else -> nil
      end
    end

    #------------------------
    # by_guid__mnesia
    #------------------------
    def by_guid__mnesia(guid, _context, _options \\ nil) do
      case JetzySchema.Database.User.Guid.Lookup.Table.match!([guid: guid]) |> Amnesia.Selection.values() do
        [%{__struct__: JetzySchema.Database.User.Guid.Lookup.Table} = entity | _] -> entity.user
        _ -> nil
      end
    end


    #------------------------
    # by_guid__redis
    #------------------------
    def by_guid__redis(_guid, _context, _options \\ nil) do
      nil
    end


    #------------------------
    # by_guid__ecto
    #------------------------
    def by_guid__ecto(guid, _context, _options \\ nil) do
      query = from r in JetzySchema.PG.User.Guid.Lookup.Table,
                   where: r.guid == ^guid,
                   select: r,
                   limit: 1
      case JetzySchema.PG.Repo.all(query) do
        [resolution | _] -> resolution.user
        _ -> nil
      end
    end
  end

end
