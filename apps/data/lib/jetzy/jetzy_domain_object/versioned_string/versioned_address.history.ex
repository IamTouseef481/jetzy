#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.VersionedAddress.History do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "v-address-h"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}

  #=======================================================================================
  # Entity
  #=======================================================================================
  defmodule Entity do
    @nmid_index 150
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      public_field :versioned_address

      @json_ignore [:mobile, :verbose_mobile]
      public_field :editor

      @json_ignore [:mobile]
      public_field :revision, 0

      public_field :url
      public_field :icon

      public_field :name
      public_field :official_name
      public_field :description
      public_field :note

      public_field :address_type
      public_field :address_line_one
      public_field :address_line_two
      public_field :intersection
      public_field :postal_code

      public_field :address_country
      public_field :address_state
      public_field :address_city

      public_field :geo

      @json_ignore [:mobile]
      internal_field :moderation, nil, type: Jetzy.ModerationDetails.TypeHandler

      @json_ignore [:mobile]
      public_field :modified_on, nil, type:  Noizu.DomainObject.DateTime.Millisecond.TypeHandler
    end




  end


  #=======================================================================================
  # Repo
  #=======================================================================================
  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end
  end
end
