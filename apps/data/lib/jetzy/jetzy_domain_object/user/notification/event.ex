#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Notification.Event do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "user-notification-event"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, cascade?: true}
  #@index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]]}
  # Pending Implementation: @index {Jetzy.Admin.Index, pii: :level_0, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: false]}]}
  defmodule Entity do
    @nmid_index 339
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :user, nil, Noizu.DomainObject.UUID.UniversalLink.TypeHandler
      public_field :sender, nil, Noizu.DomainObject.UUID.UniversalLink.TypeHandler
      public_field :subject, nil, Noizu.DomainObject.UUID.UniversalLink.TypeHandler
      public_field :notification_type
      public_field :status
      public_field :viewed_on, nil, Noizu.DomainObject.DateTime.Second.TypeHandler
      public_field :cleared_on, nil, Noizu.DomainObject.DateTime.Second.TypeHandler
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end

    def mark_read(this, context, options) do
      options = put_in(options || [], [:with_upsert!], true)
      %{this| viewed_on: DateTime.utc_now(), status: :viewed} |> Jetzy.User.Notification.Event.Repo.update!(context, options)
    end

    def mark_cleared(this, context, options) do
      options = put_in(options || [], [:with_upsert!], true)
      %{this| cleared_on: DateTime.utc_now(), status: :cleared} |> Jetzy.User.Notification.Event.Repo.update!(context, options)
    end

    #===-------
    # has_permission?
    #===-------
    def has_permission?(_entity, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_entity, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

    #===-------
    # has_permission!
    #===-------
    def has_permission!(_entity, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_entity, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true
  end

  defmodule Repo do
    Noizu.DomainObject.noizu_repo do
    end

    import Ecto.Query

    def query(user, since_record, rpp, context, options) do
      user_ref = Noizu.ERP.ref(user)
      rpp = rpp || 250
      since_record = Noizu.ERP.id(since_record)
      query = cond do
        since_record ->
         query = from e in JetzySchema.PG.User.Notification.Event.Table,
                 where: e.user == ^user_ref,
                 where: e.identifier < ^since_record,
                 limit: ^rpp,
                 order_by: [desc: e.identifier],
                 select: e.identifier

        :else ->
          query = from e in JetzySchema.PG.User.Notification.Event.Table,
                       where: e.user == ^user_ref,
                       limit: ^rpp,
                       order_by: [desc: e.identifier],
                       select: e.identifier
      end
      entities = Enum.map(JetzySchema.PG.Repo.all(query), fn(identifier) -> Jetzy.User.Notification.Event.Entity.entity!(identifier) end) |> Enum.filter(&(&1))
      %Jetzy.User.Notification.Event.Repo{
        length: length(entities),
        entities: entities
      }
    end

    def meta_data(user, context, options) do
      user_ref = Noizu.ERP.ref(user)
      total_query = from e in JetzySchema.PG.User.Notification.Event.Table,
                         where: e.user == ^user_ref,
                         select: count(e.identifier)
      total = JetzySchema.PG.Repo.one(total_query)

      read_query = from e in JetzySchema.PG.User.Notification.Event.Table,
                         where: e.user == ^user_ref,
                         where: e.status == :viewed,
                         select: count(e.identifier)
      read = JetzySchema.PG.Repo.one(read_query)

      cleared_query = from e in JetzySchema.PG.User.Notification.Event.Table,
                        where: e.user == ^user_ref,
                        where: e.status == :cleared,
                        select: count(e.identifier)
      cleared = JetzySchema.PG.Repo.one(cleared_query)

      pending_query = from e in JetzySchema.PG.User.Notification.Event.Table,
                           where: e.user == ^user_ref,
                           where: e.status == :pending,
                           select: count(e.identifier)
      pending = JetzySchema.PG.Repo.one(pending_query)


      %{
        unread: pending,
        read: read,
        cleared: cleared,
        total: total
      }
    end


    
    def extract_subject!(notification_type, %JetzySchema.MSSQL.Notification.Record.Table{} = record, context, options) do
      case notification_type do
        :friend_request_sent ->
          r = record.pending_friend_request && String.to_integer(record.pending_friend_request)
          Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.User.Friend.Table, r, context, options)
        :friend_request_accepted -> nil
        :post_like ->
          r = record.shoutout_id && String.to_integer(record.shoutout_id)
          Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Post.Table, r, context, options)
        :post_comment ->
          r = record.shoutout_id && String.to_integer(record.shoutout_id)
          Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Post.Table, r, context, options)
        :reply ->
          r = record.shoutout_id && String.to_integer(record.shoutout_id)
          Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Post.Table, r, context, options)
        :referral_complete -> nil
        :tagged_in_post ->
          r = record.shoutout_id && String.to_integer(record.shoutout_id)
          Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Post.Table, r, context, options)
        :tagged_in_comment ->
          r = record.shoutout_id && String.to_integer(record.shoutout_id)
          Jetzy.LegacyResolution.Repo.by_legacy!(JetzySchema.MSSQL.Post.Table, r, context, options)
        :message_received -> nil
        :post_local_user -> nil
        :private_group_invitation -> nil
        :private_group_request -> nil
      end
    end
    
    def import!(%JetzySchema.MSSQL.Notification.Record.Table{} = record, context, options) do
      cond do
        ref = Jetzy.LegacyResolution.Repo.by_type_and_legacy!(Jetzy.User.Notification.Event.Entity, record.__struct__, record.id, context, options) -> {:error, {:exists, ref}}
        :else ->
  
          notification_type = Jetzy.User.Notification.Type.Repo.extract_type(record.description, context, options)
          user = Jetzy.User.Repo.by_guid!(record.receiver_id, context, options) |> Noizu.ERP.ref
          sender = Jetzy.User.Repo.by_guid!(record.sender_id, context, options) |> Noizu.ERP.ref
          subject = extract_subject!(notification_type, record, context, options)
          status = :pending
          time_stamp = JetzySchema.MSSQL.Notification.Record.Table.time_stamp(record, context, options)
          imported = %Jetzy.User.Notification.Event.Entity{
            user: user,
            sender: sender,
            subject: subject,
            notification_type: notification_type,
            status: status,
            viewed_on: nil,
            cleared_on: nil,
            time_stamp: time_stamp,
            meta: [source: {record.__struct__, record.id}]
          } |> Jetzy.User.Notification.Event.Repo.create!(context, options)
          if (imported.identifier) do
            ref = Noizu.ERP.ref(imported)
            Jetzy.LegacyResolution.Repo.insert!(ref, record.__struct__, record.id, context, options)
            {:imported, imported}
          else
            {:error, imported}
          end
      end
    end

    #===-------
    # has_permission?
    #===-------
    def has_permission?(_, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_, %Noizu.ElixirCore.CallingContext{}, _options), do: true
    def has_permission?(_repo, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_repo, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

    #===-------
    # has_permission!
    #===-------
    def has_permission!(_, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_, %Noizu.ElixirCore.CallingContext{}, _options), do: true
    def has_permission!(_repo, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_repo, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

  end
end
