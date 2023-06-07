#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Contact.Channel.Field do
  @doc """
    @todo - need user_channel table (there should be an analogous table already for this.  ( entity_contact_channel ) - move this to Entity.Contact.Channel
    @todo - need communication_channel table to define a communication type and handler
    @todo - communication handler enum type and table
  """

  use Noizu.DomainObject
  @vsn 1.0
  @sref "contact-field"
  @persistence_layer {:mnesia, cascade_block?: true}
  @persistence_layer {:ecto, [cascade?: true, cascade_block?: true]}
  defmodule Entity do
    @nmid_index 79
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid

      public_field :contact_channel
      public_field :channel_definition_field
      public_field :value
      public_field :modified_on, nil,  Noizu.DomainObject.DateTime.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end
  end

end
