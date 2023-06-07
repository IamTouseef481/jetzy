#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.ChatRoom do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "chat-room"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  defmodule Entity do
    @universal_identifier true
    @nmid_index 68
    Noizu.DomainObject.noizu_entity do
      identifier :integer  # Same as user
      public_field :slug
      public_field :description, nil, Jetzy.UserVersionedString.TypeHandler
      public_field :status
      public_field :type
      public_field :owner
      public_field :permissions
      public_field :members
      public_field :blocked
      public_field :muted

      @index true
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end


    def terminate_hook(_a,_b), do: nil

  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end
  end
end
