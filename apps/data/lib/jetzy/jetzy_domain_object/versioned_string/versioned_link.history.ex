#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.VersionedLink.History do
  use Jetzy.VersionedString.HistoryBehavior

  @vsn 1.0
  @sref "v-link-h"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}

  #=======================================================================================
  # Entity
  #=======================================================================================
  defmodule Entity do
    @nmid_index 158
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      public_field :versioned_link

      @json_ignore [:mobile, :verbose_mobile]
      public_field :editor

      @json_ignore [:mobile]
      public_field :revision, 0

      public_field :name, ""
      public_field :description, ""
      public_field :link, ""

      @json_ignore [:mobile]
      public_field :modified_on, nil, type: Noizu.DomainObject.DateTime.Millisecond.TypeHandler

      @json_ignore [:mobile]
      internal_field :moderation, nil, type: Jetzy.ModerationDetails.TypeHandler
    end


  end

  #=======================================================================================
  # Repo
  #=======================================================================================
  defmodule Repo do
    use Jetzy.VersionedString.HistoryBehavior.Repo
  end

end
