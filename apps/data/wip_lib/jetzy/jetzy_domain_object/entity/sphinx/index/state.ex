#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Sphinx.Index.State do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "entity-sphinx-state"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  defmodule Entity do
    @nmid_index 82
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :integer

      @index true
      internal_field :subject, nil, Noizu.DomainObject.UUID.UniversalLink.TypeHandler

      @index true
      internal_field :sphinx_index

      @index true
      internal_field :sphinx_index_type

      @index true
      restricted_field :modified_on, nil,  Noizu.DomainObject.TimeStamp.Millisecond.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end
  end

end
