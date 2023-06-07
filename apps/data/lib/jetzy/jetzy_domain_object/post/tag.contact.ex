#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Post.Tag.Contact do

  use Noizu.DomainObject
  @vsn 1.0
  @sref "post-tag-contact"
  @persistence_layer :ecto
  defmodule Entity do
    @nmid_index 299
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :name
      public_field :email
      public_field :mobile
      public_field :status, JetzySchema.Types.Status.Enum
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end
  end
end
