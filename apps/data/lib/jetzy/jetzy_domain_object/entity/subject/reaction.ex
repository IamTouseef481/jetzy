
#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Entity.Subject.Reaction do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "entity-reaction"
  @persistence_layer :ecto
  @auto_generate false
  defmodule Entity do
    require Logger
    @nmid_index 84
    @universal_identifier false
    Noizu.DomainObject.noizu_entity do
      identifier :compound
      public_field :for_entity # User who has interacted with subject
      public_field :subject # entity being liked/disliked/hearted etc.
      @ref Jetzy.Entity.Subject.Reaction.History.Entity
      public_field :history_event
      @enum Jetzy.Reaction.Type.Enum
      public_field :reaction #, nil, JetzySchema.Types.Reaction.Type.Enum
      public_field :modified_on, nil,  Noizu.DomainObject.DateTime.Second.TypeHandler
    end
  end

  defmodule Repo do
    require Logger
    Noizu.DomainObject.noizu_repo do

    end

    def import!(%JetzySchema.MSSQL.LikeDetail.Table{} = record, context, options) do
      case Jetzy.Entity.Subject.Reaction.History.Repo.import!(record, context, options) do
        {update_type, history_event} ->
          identifier = {history_event.for_entity, history_event.subject}
          insert = %Jetzy.Entity.Subject.Reaction.Entity{
                     identifier: identifier,
                     for_entity: history_event.for_entity,
                     subject: history_event.subject,
                     history_event: Noizu.ERP.ref(history_event),
                     reaction: history_event.reaction,
                     modified_on: history_event.modified_on
                   } |> Jetzy.Entity.Subject.Reaction.Repo.create!(context)

          subject = Noizu.ERP.entity!(options[:subject])
          user = subject && Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.User, Noizu.ERP.ref(history_event.for_entity), context, options)
          post = subject && Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.UserEvent, Noizu.ERP.ref(subject), context, options)
          cond do
            user && post ->
              record = %{
                         deleted_at: nil,
                         item_id: Noizu.ERP.id(post),
                         liked: true,
                         like_source_id: "44b49d92-7fff-11ec-9487-a45e60e7f2b3",
                         user_id: Noizu.ERP.id(user),
                         inserted_at: history_event.modified_on,
                         updated_at: history_event.modified_on,
                       }
              Data.Context.create(Data.Schema.UserEventLike, record)
            :else ->
              Logger.error "User Post load failed for #{inspect subject}"
          end

          {update_type, insert}
        _ -> {:error, :history_event_import}
      end
    end

    def pre_create_callback(entity, context, options) do
      entity = %{entity| identifier: {Noizu.ERP.ref(entity.for_entity), Noizu.ERP.ref(entity.subject)}}
      super(entity, context, options)
    end

  end

end
