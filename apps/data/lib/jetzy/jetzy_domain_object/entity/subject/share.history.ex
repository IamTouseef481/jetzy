
#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Subject.Share.History do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "entity-share-event"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  @auto_generate true
  defmodule Entity do
    @nmid_index 86
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      @ref true
      public_field :for_entity # User who has interacted with subject
      @ref true
      public_field :subject # entity being liked/disliked/hearted etc.
      @ref true
      public_field :share
      @enum Jetzy.Share.Event.Type.Enum
      public_field :share_event_type #, nil, JetzySchema.Types.Share.Event.Type.Enum
      public_field :count
      public_field :created_on, nil,  Noizu.DomainObject.DateTime.Millisecond.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end

    def record_comment_event(type, for_entity, subject, share, modified_on , context, options) do
      count = cond do
                type == :none -> 0
                type == [:share, :quote_share] -> 1
                type in [:unshare, :system_remove, :moderator_remove] -> -1
              end

      %Jetzy.Entity.Subject.Share.History.Entity{
        for_entity: Noizu.ERP.ref(for_entity),
        subject: Noizu.ERP.ref(subject),
        share: Noizu.ERP.ref(share),
        created_on: modified_on,
        share_event_type: type,
        count: count
      } |> Jetzy.Entity.Subject.Share.History.Repo.create!(context, options)
    end

  end

end
