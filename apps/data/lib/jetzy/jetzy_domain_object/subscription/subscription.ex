#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Subscription do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "subscription-definition"
  @persistence_layer :mnesia
  defmodule Entity do
    @nmid_index 166
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :handle
      public_field :subscription_group
      public_field :description, nil, Jetzy.VersionedString.TypeHandler
      public_field :details
      public_field :features
    end

    def description(this) do
      with {:ok, this} <- entity_ok!(this) do
        Noizu.ERP.entity!(this.description)
      end
    end

    def payment_details(this, payment_provider, context, options) do
      with {:ok, this} <- entity_ok!(this) do
        d = %{
          subscription_data: this.details[:stripe][:subscription_data]
        }
        {:ok, d}
      else
        _ -> {:error, :not_found}
      end
    end
  end
  
  defmodule Repo do
    # import Ecto.Query, only: [from: 2]
    Noizu.DomainObject.noizu_repo do

    end

    def add_trial(user, subscription_handle, context, options \\ []) do
      period = options[:period] || [months: 1]
      cs = DateTime.utc_now()
      ce = Timex.shift(cs, period)
      trial = %Jetzy.User.Subscription.Entity{
        user: Jetzy.User.Entity.ref(user),
        subscription_definition: Jetzy.Subscription.Repo.by_handle(subscription_handle),
        status: :active,
        coverage_start: cs,
        coverage_end: ce
      } |> Jetzy.User.Subscription.Repo.create!(context)
      options[:welcome_email] && Jetzy.User.Subscription.Entity.welcome_email(user, trial, context, options)
      trial
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
        JetzySchema.Database.Subscription.Table.match!([handle: handle])
        |> Amnesia.Selection.values()
        |> case do
             [%{entity: e}|_] -> Noizu.ERP.ref(e)
             _ -> nil
           end
      end)
    end
    
  end
end
