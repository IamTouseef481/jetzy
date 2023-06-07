#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Share do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "entity-share"
  @persistence_layer :mnesia
  #@persistence_layer :ecto
  defmodule Entity do
    @nmid_index 91
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :status
      public_field :subject
      public_field :share_type
      public_field :share_with
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end
  end

end
