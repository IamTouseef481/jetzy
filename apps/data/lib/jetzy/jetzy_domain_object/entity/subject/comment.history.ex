
#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Subject.Comment.History do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "entity-comment-event"
  @persistence_layer :mnesia
  @persistence_layer :ecto
  @auto_generate true
  defmodule Entity do
    @nmid_index 83
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      @ref true
      public_field :for_entity # User who has interacted with subject
      @ref true
      public_field :subject # entity being liked/disliked/hearted etc.
      @ref true
      public_field :comment
      @enum Jetzy.Comment.Event.Type.Enum
      public_field :comment_event_type #, nil, JetzySchema.Types.Comment.Event.Type.Enum
      public_field :count
      public_field :modified_on, nil,  Noizu.DomainObject.DateTime.Second.TypeHandler
    end
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do

    end

    def record_comment_event(type, for_entity, subject, comment, modified_on , context, options) do
      count = cond do
                type == :none -> 0
                type == :comment -> 1
                type in [:uncomment, :system_remove, :moderator_remove] -> -1
              end

      %Jetzy.Entity.Subject.Comment.History.Entity{
        for_entity: Noizu.ERP.ref(for_entity),
        subject: Noizu.ERP.ref(subject),
        comment: Noizu.ERP.ref(comment),
        modified_on: modified_on,
        comment_event_type: type,
        count: count
      } |> Jetzy.Entity.Subject.Comment.History.Repo.create!(context, options)
    end

  end

end
