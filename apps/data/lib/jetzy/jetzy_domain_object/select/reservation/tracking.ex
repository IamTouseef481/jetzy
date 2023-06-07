#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Select.Reservation.Tracking do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "select-reservation"
  @persistence_layer {:mnesia, cascade_block?: true}
  defmodule Entity do
    require Logger
    use Amnesia
    @nmid_index 345
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :status
      public_field :code
      public_field :initial_request
      public_field :user
      @json_embed {:verbose_mobile, [:created_on, :modified_on, :deleted_on]}
      @json_embed {:mobile, [:created_on, :modified_on, :deleted_on]}
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
    #import Ecto.Query, only: [from: 2]
    require Logger
    Noizu.DomainObject.noizu_repo do
    
    end
    
    def generate_code(user, context, options) do
      uid_prefix = Jetzy.User.Entity.id(user)
                   |> UUID.binary_to_string!()
                   |> String.slice(0..3)
      sequencer = {:select_code, uid_prefix}
      c = Noizu.AdvancedScaffolding.NmidGenerator.bare!(sequencer)
          |> Integer.to_string(16)
          |> String.pad_leading(4, "0")
      "R#{uid_prefix}#{c}"
      |> String.upcase()
    end

    def by_code(code, _context, _options \\ nil) do
      m = JetzySchema.Database.Select.Reservation.Tracking.Table.match!([code: code])
          |> Amnesia.Selection.values()
      case m do
        [h|_] -> h
        _ -> nil
      end
    end
    
    def new(user, reservation, context, options \\ nil) do
      user = Jetzy.User.Entity.ref(user)
      code = generate_code(user, context, options)
      this = %Jetzy.Select.Reservation.Tracking.Entity{
        status: :pending,
        code: code,
        user: user,
        initial_request: reservation,
        time_stamp: Noizu.DomainObject.TimeStamp.Second.now()
      }
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
