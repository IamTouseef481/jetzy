#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.ChatRoom.Message do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "chat-message"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  defmodule Entity do
    @universal_identifier true
    @nmid_index 67
    Noizu.DomainObject.noizu_entity do
      identifier :integer  # Same as user
      public_field :chat_room,
      public_field :user
      public_field :type
      public_field :urgent
      public_field :message, nil, Jetzy.UserVersionedString.TypeHandler
      public_field :moderation, nil, Jetzy.ModerationDetails.TypeHandler
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end


  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end

    def pull(_chat_room, _current_time, _cut_off, _context) do
      %__MODULE__{
          entities: [],
          length: 0
      }
    end

  end
end
