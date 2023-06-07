#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Offer.Deal.Attribute do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "deal-attr"
  @persistence_layer :ecto
  defmodule Entity do
    @nmid_index 109
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :integer

      @ref Jetzy.Offer.Deal.Entity
      public_field :offer_deal

      public_field :attribute

      public_field :value

      public_field :description, nil, Jetzy.VersionedString.TypeHandler

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end




  end

end
