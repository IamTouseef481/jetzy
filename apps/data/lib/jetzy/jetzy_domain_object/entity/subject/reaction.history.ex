
#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Subject.Reaction.History do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "entity-reaction-event-history"
  #@persistence_layer :mnesia
  @persistence_layer :ecto
  @auto_generate true
  defmodule Entity do
    @nmid_index 85
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :for_entity # User who has interacted with subject
      public_field :subject # entity being liked/disliked/hearted etc.
      @enum Jetzy.Reaction.Type.Enum
      public_field :reaction #, nil, JetzySchema.Types.Reaction.Type.Enum
      @enum Jetzy.Reaction.Event.Type.Enum
      public_field :reaction_event_type #, nil, JetzySchema.Types.Reaction.Event.Type.Enum
      public_field :count
      public_field :modified_on, nil,  Noizu.DomainObject.DateTime.Millisecond.TypeHandler
    end
  end

  defmodule Repo do
    @like_source %{
      post: 1,
      comment: 2,
    }

    Noizu.DomainObject.noizu_repo do

    end



    def post_create_callback(entity, context, options) do
      cond do
        entity.count > 0 -> Jetzy.Entity.Interactions.Repo.increment!(entity.subject, entity.reaction, context, options)
        entity.count < 0 -> Jetzy.Entity.Interactions.Repo.decrement!(entity.subject, entity.reaction, context, options)
        :else -> :nop
      end
      entity
    end


    def import!(%JetzySchema.MSSQL.LikeDetail.Table{} = record, context, options) do
      cond do
        history_event = Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.LikeDetail.Table, record.id, context, options) |> Noizu.ERP.entity!() ->
          {:refresh, history_event}
        :else ->
          entity = Jetzy.User.Repo.by_guid!(record.user_id, context, options)
          subject = cond do
                      options[:subject] -> options[:subject]
                      record.like_source_identifier == @like_source.post -> Jetzy.Post.Repo.by_legacy!(record.item_id, context, options)
                      record.like_source_identifier == @like_source.comment -> Jetzy.Comment.Repo.by_legacy!(record.item_id, context, options)
                    end
          {reaction, event_type, count} = cond do
                                            record.liked -> {:like, :add, 1}
                                            :else ->  {:none, :none, 0}
                                          end
          history_event = %Jetzy.Entity.Subject.Reaction.History.Entity{
                            for_entity: Noizu.ERP.ref(entity),
                            subject: Noizu.ERP.ref(subject),
                            reaction: reaction,
                            reaction_event_type: event_type,
                            count: count,
                            modified_on: record.modified_on
                          } |> Jetzy.Entity.Subject.Reaction.History.Repo.create!(context, options)
          Jetzy.LegacyResolution.Repo.insert!(Noizu.ERP.ref(history_event), JetzySchema.MSSQL.LikeDetail.Table, record.id, context, options)
          {:imported, history_event}
      end
    end

  end

end
