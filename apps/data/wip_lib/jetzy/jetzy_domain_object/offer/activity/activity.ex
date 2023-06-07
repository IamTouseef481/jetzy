#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Offer.Activity do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "activity"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  defmodule Entity do
    @nmid_index 108
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :integer

      @index true
      public_field :activity_source

      @index true
      public_field :activity_type

      @index true
      public_field :subject

      @index true
      public_field :description, nil, Jetzy.VersionedString.TypeHandler

      @index true
      public_field :details # cms

      @index true
      public_field :featured

      @index true
      public_field :display_discount

      @index true
      public_field :active

      @index true
      public_field :price

      @index true
      public_field :duration

      @index true
      public_field :valid_from, nil,  Noizu.DomainObject.DateTime.Second.TypeHandler

      @index true
      public_field :valid_until, nil,  Noizu.DomainObject.DateTime.Second.TypeHandler

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end




  end

end
