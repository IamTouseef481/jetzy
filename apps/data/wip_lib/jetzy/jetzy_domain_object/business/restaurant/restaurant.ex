#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Business.Restaurant do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "restaurant"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  #@permissions [{[:edit, :view], :user}, {[:view,:index], :restricted}]
  @index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: []]}
  @index {Jetzy.Admin.Index, pii: :level_0, default: []}
  defmodule Entity do
    @nmid_index 59
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :integer

      @index true
      public_field :owner

      @index true
      public_field :description, nil, Jetzy.VersionedBusiness.TypeHandler

      @index true
      public_field :details

      @index true
      public_field :attributes

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end




  end

end
