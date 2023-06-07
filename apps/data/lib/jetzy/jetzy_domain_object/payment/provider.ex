#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Payment.Provider do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "item"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, [cascade?: true, fallback?: true, cascade_block?: true]}
  defmodule Entity do
    @nmid_index 172
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :description, nil, Jetzy.VersionedString.TypeHandler
      @index true
      @json_ignore :*
      @json_embed {:verbose_mobile, [:created_on, :modified_on]}
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
    
    @payment_provider_by_handle %{
      stripe: {:ref, Jetzy.Payment.Provider.Entity, UUID.string_to_binary!("cb20bb7d-e752-4529-a974-4dd2cbad68fc")}
    }
    def ref_ok(:stripe), do: {:ok, @payment_provider_by_handle[:stripe]}
    def ref_ok(ref), do: super(ref)
    
    def ref(:stripe), do: @payment_provider_by_handle[:stripe]
    def ref(ref), do: super(ref)
    
    #------------------------------
    #
    #------------------------------
    def __from_record__(l = %{schema: JetzySchema.PG.Repo}, entity, context, options) do
      __from_record__!(l, entity, context, options)
    end
    def __from_record__(layer,entity,context,options), do: super(layer, entity, context, options)

    #------------------------------
    #
    #------------------------------
    def __from_record__!(_l = %{schema: JetzySchema.PG.Repo}, entity, context, options) do
      if entity do
        entity = %__MODULE__{
          identifier: UUID.string_to_binary!(entity.identifier),
          description: entity.description,
          time_stamp: %Noizu.DomainObject.TimeStamp.Second{
            created_on: entity.created_on,
            modified_on: entity.modified_on,
            deleted_on: entity.deleted_on
          }
        }
        # Auto inject
        options_b = update_in(options || [], [JetzySchema.PG.Repo], &(put_in(&1 || [], [:cascade?], false)))
        Jetzy.Payment.Provider.Repo.create!(entity, Noizu.ElixirCore.CallingContext.system(context), options_b)
      end
    end
    def __from_record__!(layer,entity,context,options), do: super(layer, entity, context, options)
  end
  
  defmodule Repo do
    # import Ecto.Query, only: [from: 2]
    Noizu.DomainObject.noizu_repo do
    end
  
  end
end
