#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Channel.Definition.Field do
  @doc """
    @todo - need user_channel table (there should be an analogous table already for this.
    @todo - need communication_channel table to define a communication type and handler
    @todo - communication handler enum type and table
  """

  use Noizu.DomainObject
  @vsn 1.0
  @sref "communication-channel-field"
  @persistence_layer {:mnesia, cascade_block?: true}
  @persistence_layer {:ecto, cascade?: true}
  defmodule Entity do
    @nmid_index 340
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid  # Same as user
      public_field :channel_definition
      public_field :field_type
      public_field :validation
      public_field :weight
      public_field :description, nil, Jetzy.VersionedString.TypeHandler
      public_field :modified_on, nil, Noizu.DomainObject.DateTime.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end
  end
end
