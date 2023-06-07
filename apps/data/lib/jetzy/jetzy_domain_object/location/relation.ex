#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Location.Relation do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "location-relation"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  defmodule Entity do
    @nmid_index 103
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      @index true
      public_field :location

      @index true
      public_field :location_relation

      @index true
      public_field :location_relation_type

      @index true
      @pii :level_2
      public_field :added_by

      @index true
      public_field :description, nil, Jetzy.LocationVersionedString.TypeHandler

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end
  end

end
