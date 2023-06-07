#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Location.AlternativeName do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "location-alt"
  @persistence_layer :ecto
  @universal_identifier false
  @universal_lookup false
  @auto_generate false
  defmodule Entity do
    @nmid_index 97
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :location
      @pii :level_2
      public_field :added_by
      public_field :alternative_name
      public_field :status
      public_field :moderation
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end
  end

end
