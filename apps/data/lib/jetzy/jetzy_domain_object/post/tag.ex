#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Post.Tag do

  use Noizu.DomainObject
  @vsn 1.0
  @sref "post-tag"
  @persistence_layer :ecto
  defmodule Entity do
    @nmid_index 114
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :post, nil, JetzySchema.Types.Universal.Reference
      public_field :tagged, nil, JetzySchema.Types.Universal.Reference
      public_field :contact, nil, JetzySchema.Types.Universal.Reference
      public_field :tagged_by, nil, JetzySchema.Types.Universal.Reference
      public_field :blocked_by, nil, JetzySchema.Types.Universal.Reference
      public_field :status, nil, JetzySchema.Types.Status.Enum
      public_field :tag_type, nil, JetzySchema.Types.Tag.Type.Enum
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end
  end
end
