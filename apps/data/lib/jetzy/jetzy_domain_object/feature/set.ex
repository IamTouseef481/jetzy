#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Feature.Set do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "feature-set"
  @persistence_layer :mnesia
  defmodule Entity do
    @nmid_index 169
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :handle
      public_field :description, nil, Jetzy.VersionedString.TypeHandler
      public_field :features
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
        JetzySchema.Database.Feature.Set.Table.match!([handle: handle])
        |> Amnesia.Selection.values()
        |> case do
             [%{entity: e}|_] -> Noizu.ERP.ref(e)
             _ -> nil
           end
      end)
    end
    
    
  end
end
