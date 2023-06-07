#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Subscription.Group do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "subscription-group-definition"
  @persistence_layer :mnesia
  defmodule Entity do
    @nmid_index 171
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :handle
      public_field :description, nil, Jetzy.VersionedString.TypeHandler
    end
  end
  
  defmodule Repo do
    # import Ecto.Query, only: [from: 2]
    Noizu.DomainObject.noizu_repo do
    
    
    
    end


    def post_create_callback(entity, context, options) do
      if entity do
        cache_key = :"handle.#{__sref__()}.#{entity.handle}"
        FastGlobal.delete(cache_key) # @todo async all nodes.
      end
      super(entity, context, options)
    end


    def post_update_callback(entity, context, options) do
      if entity do
        cache_key = :"handle.#{__sref__()}.#{entity.handle}"
        FastGlobal.delete(cache_key) # @todo async all nodes.
      end
      super(entity, context, options)
    end
    
    def by_handle(handle) when is_bitstring(handle) do
      cache_key = :"handle.#{__sref__()}.#{handle}"
      Noizu.FastGlobal.V3.Cluster.get(cache_key, fn() ->
        JetzySchema.Database.Subscription.Group.Table.match!([handle: handle])
        |> Amnesia.Selection.values()
        |> case do
             [%{entity: e}|_] -> Noizu.ERP.ref(e)
             _ -> nil
           end
      end)
    end
    
  end
end
