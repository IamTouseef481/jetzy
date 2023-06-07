#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Feature do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "feature"
  @persistence_layer :mnesia
  defmodule Entity do
    @nmid_index 168
    @universal_identifier false
    @universal_lookup false
    @auto_generate false
    Noizu.DomainObject.noizu_entity do
      identifier :atom
      public_field :description, nil, Jetzy.VersionedString.TypeHandler
    end
  end
  
  defmodule Repo do
    # import Ecto.Query, only: [from: 2]
    Noizu.DomainObject.noizu_repo do
    
    end
    
    
  end
end
