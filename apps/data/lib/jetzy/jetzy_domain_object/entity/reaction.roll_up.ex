
#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Reaction.RollUp do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "entity-reaction-rollup"
  # @TODO @pri0 we don't need a mnesia copy just an ecto one.
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  @auto_generate false
  defmodule Entity do
    @nmid_index 90
    @universal_identifier false
    @primary_key :none
    require Logger
    Noizu.DomainObject.noizu_entity do
      identifier :compound # {ref, reaction}
      @json_ignore [:mobile, :verbose_mobile]
      public_field :subject # User who has interacted with subject
      public_field :reaction # entity being liked/disliked/hearted etc.
      public_field :tally
      public_field :synchronized_on, nil,  Noizu.DomainObject.DateTime.Millisecond.TypeHandler
    end

    def ecto_identifier(_entity) do
      Logger.info "NOT_SUPPORTED #{__MODULE__}.#{elem(__ENV__.function, 0)}/#{elem(__ENV__.function, 1)}"
      
      nil
    end

  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end

    def pre_create_callback(entity, context, options) do
      entity = %{entity| identifier: entity.identifier || {Noizu.ERP.ref(entity.subject), entity.reaction}}
      super(entity, context, options)
    end
    def pre_create_callback!(entity, context, options) do
      entity = %{entity| identifier: entity.identifier || {Noizu.ERP.ref(entity.subject), entity.reaction}}
      super(entity, context, options)
    end

  end

end
