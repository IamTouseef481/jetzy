#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------
defmodule Jetzy.OperatingSystem do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "operating-system"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  defmodule Entity do
    @nmid_index 111
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      @index true
      public_field :description, nil, Jetzy.VersionedString.TypeHandler

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end
  end

end
