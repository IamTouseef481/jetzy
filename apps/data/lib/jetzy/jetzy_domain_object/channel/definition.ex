#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Channel.Definition do
  @doc """
    @todo - need user_channel table (there should be an analogous table already for this.
    @todo - need communication_channel table to define a communication type and handler
    @todo - communication handler enum type and table
  """

  use Noizu.DomainObject
  @vsn 1.0
  @sref "communication-channel"
  @persistence_layer {:mnesia, cascade_block?: true}
  @persistence_layer {:ecto, cascade?: true}
  defmodule Entity do
    @nmid_index 66
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid  # Same as user
      public_field :handle
      public_field :channel_handler
      public_field :description, nil, Jetzy.VersionedString.TypeHandler
      public_field :fields, nil, Jetzy.Channel.Definition.Field.Repo.TypeHandler

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
  end

  defmodule Repo do
    def by_type(type, context, options) do
      JetzySchema.Database.Channel.Definition.Table.match(handle: "#{type}")
      |> Amnesia.Selection.values
      |> case do
          [h|_] -> h.entity
          _ -> nil
         end
    end
    def by_type!(type, context, options) do
      JetzySchema.Database.Channel.Definition.Table.match!(handle: "#{type}")
      |> Amnesia.Selection.values
      |> case do
           [h|_] -> h.entity
           _ -> nil
         end
    end

    Noizu.DomainObject.noizu_repo do
    end
  end
end
