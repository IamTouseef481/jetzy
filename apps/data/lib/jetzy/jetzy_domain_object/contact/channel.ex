#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Contact.Channel do
  @doc """
    @todo - need user_channel table (there should be an analogous table already for this.  ( entity_contact_channel ) - move this to Entity.Contact.Channel
    @todo - need communication_channel table to define a communication type and handler
    @todo - communication handler enum type and table
  """

  use Noizu.DomainObject
  @vsn 1.0
  @sref "contact-channel"
  @persistence_layer {:mnesia, cascade_block?: true}
  @persistence_layer {:ecto, [cascade?: true, cascade_block?: true]}
  defmodule Entity do
    @nmid_index 78
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid  # Same as user

      public_field :channel_definition
      public_field :description, nil, Jetzy.UserVersionedString.TypeHandler
      public_field :moderation, nil, Jetzy.ModerationDetails.TypeHandler
      public_field :fields, nil, Jetzy.Contact.Channel.Field.Repo.TypeHandler

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end
  end

end
