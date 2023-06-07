#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Location.Source.Google do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "location-source-google"
  @persistence_layer :ecto
  defmodule Entity do
    @nmid_index 104
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :location
      public_field :location_type

      @pii :level_2
      public_field :added_by

      public_fields [:hash, :place, :url, :icon, :address, :raw]

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end
  end

end
