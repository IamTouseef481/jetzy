#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------
defmodule Jetzy.Device do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "device"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  #@permissions [{[:edit, :view], :user}, {[:view,:index], :restricted}]
  defmodule Entity do
    @nmid_index 80
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      @pii :level_3
      identifier :integer

      @pii :level_2
      @index true
      restricted_field :finger_print

      @pii :level_2
      @index true
      restricted_field :device_uuid

      @pii :level_2
      @index true
      restricted_field :operating_system

      @pii :level_2
      @index true
      restricted_field :device_type

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end


  end

  defmodule Repo do
    #import Ecto.Query, only: [from: 2]

    Noizu.DomainObject.noizu_repo do
    end

  end

end
