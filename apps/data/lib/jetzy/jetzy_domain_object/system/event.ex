#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.System.Event do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "system-event"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  @index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]]}
  # Pending Implementation: @index {Jetzy.Admin.Index, pii: :level_0, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]}
  defmodule Entity do
    @nmid_index 310
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      public_field :system_event_type, nil, JetzySchema.Types.System.Event.Type.Enum
      public_field :points

      @index true
      public_field :notes, nil, Jetzy.VersionedString.TypeHandler
      public_field :description, nil, Jetzy.VersionedString.TypeHandler

      @index true
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
