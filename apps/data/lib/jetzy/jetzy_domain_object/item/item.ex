#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Item do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "item"
  @persistence_layer :mnesia
  defmodule Entity do
    @nmid_index 170
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :handle
      public_field :quantity
      public_field :description, nil, Jetzy.VersionedString.TypeHandler
    end
  end
  
  defmodule Repo do
    # import Ecto.Query, only: [from: 2]
    Noizu.DomainObject.noizu_repo do
    
    
    
    end
    
  end
end
