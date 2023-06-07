defmodule JetzyModule.LegacyModule do
  import Ecto.Query, only: [from: 2]
  require Logger
  def import!(type, page, context, options \\ nil)



  def import_for_user!(guid, Jetzy.User.Notification.Event, page, context, options) do
    query = from r in JetzySchema.MSSQL.Notification.Record.Table,
                 where: r.receiver_id == ^guid,
                 select: r,
                 limit: 250,
                 offset: ^((page - 1) * 250),
                 order_by: r.id
    JetzySchema.MSSQL.Repo.all(query)
    |> Enum.map(&(Jetzy.User.Notification.Event.Repo.import!(&1, context, options)))
  end


  def import!(Jetzy.User.Notification.Event, page, context, options) do
    query = from r in JetzySchema.MSSQL.Notification.Record.Table,
                 where: 1 == 1,
                 select: r,
                 limit: 250,
                 offset: ^((page - 1) * 250),
                 order_by: r.id
    JetzySchema.MSSQL.Repo.all(query)
    |> Enum.map(&(Jetzy.User.Notification.Event.Repo.import!(&1, context, options)))
  end

  def import!(Jetzy.User.Notification.Setting, page, context, options) do
    query = from r in JetzySchema.MSSQL.Notification.Setting.Table,
                 where: 1 == 1,
                 select: r,
                 limit: 250,
                 offset: ^((page - 1) * 250),
                 order_by: r.id
    JetzySchema.MSSQL.Repo.all(query)
    |> Enum.map(&(Jetzy.User.Notification.Setting.Repo.import!(&1, context, options)))
  end

  def import!(Jetzy.Interest, page, context, options) do
    query = from r in JetzySchema.MSSQL.Interest.Table,
                 where: 1 == 1,
                 select: %{
                   r |
                   description: fragment("CAST(\"Description\" AS nvarchar(4000))")
                 },
                 limit: 250,
                 offset: ^((page - 1) * 250),
                 order_by: r.id
    JetzySchema.MSSQL.Repo.all(query)
    |> Enum.map(&(Jetzy.Interest.Repo.import!(&1, context, options)))
  end

  def import!(Jetzy.User, page, context, options) do
    query = from u in JetzySchema.MSSQL.User.Table,
                 where: 1 == 1,
                 select: %{
                   u |
                   user_about: fragment("CAST(\"UserAbout\" AS varchar(8000))"),
                   panic_message: fragment("CAST(\"PanicMessage\" AS varchar(8000))"),
                 },
                 limit: 250,
                 offset: ^((page - 1) * 250),
                 order_by: [desc: u.id]
    JetzySchema.MSSQL.Repo.all(query)
    |> Enum.map(&(Jetzy.User.Repo.import!(&1, context, options)))
  end
  
  def import!(Jetzy.User.Reward.Transaction.Event, page, context, options) do
    query = from u in JetzySchema.MSSQL.User.Reward.Transaction.Table,
                 where: 1 == 1,
                 limit: 1000,
                 offset: ^((page - 1) * 1000),
                 order_by: [desc: u.id]
    JetzySchema.MSSQL.Repo.all(query)
    |> Enum.map(
         fn(post) ->
           try do
             Jetzy.User.Reward.Transaction.Repo.import!(post, context, options)
           rescue e ->
             Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           catch
             :exit, e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
             e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           end
         end
       )
  end

  def import!(Jetzy.User.Reward.Transaction.Offer, page, context, options) do
    query = from u in JetzySchema.MSSQL.User.Offer.Transaction.Table,
                 where: 1 == 1,
                 limit: 1000,
                 offset: ^((page - 1) * 1000),
                 order_by: [desc: u.id]
    JetzySchema.MSSQL.Repo.all(query)
    |> Enum.map(
         fn(post) ->
           try do
             Jetzy.User.Reward.Transaction.Repo.import!(post, context, options)
           rescue e ->
             Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           catch
             :exit, e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
             e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           end
         end
       )
  end

  def import!(Jetzy.Post, page, context, options) do
    query = from u in JetzySchema.MSSQL.Post.Table,
                 where: 1 == 1,
                 limit: 250,
                 offset: ^((page - 1) * 250),
                 order_by: [desc: u.id]
    JetzySchema.MSSQL.Repo.all(query)
    |> Enum.map(
         fn(post) ->
           try do
             Jetzy.Post.Repo.import!(post, context, options)
           rescue e ->
             Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           catch
             :exit, e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
             e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           end
         end
       )
  end


  def import!(Jetzy.Reward.Event, page, context, options) do
    query = from u in JetzySchema.MSSQL.Reward.Manager.Table,
                 where: 1 == 1,
                 limit: 250,
                 offset: ^((page - 1) * 250),
                 order_by: [desc: u.id]
    JetzySchema.MSSQL.Repo.all(query)
    |> Enum.map(
         fn(record) ->
           try do
             Jetzy.Reward.Event.Repo.import!(record, context, options)
           rescue e ->
             Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           catch
             :exit, e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
             e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           end
         end
       )
  end

  def import!(Jetzy.Reward.Tier, page, context, options) do
    query = from u in JetzySchema.MSSQL.Reward.Tier.Table,
                 where: 1 == 1,
                 limit: 250,
                 offset: ^((page - 1) * 250),
                 order_by: [desc: u.id]
    JetzySchema.MSSQL.Repo.all(query)
    |> Enum.map(
         fn(record) ->
           try do
             Jetzy.Reward.Tier.Repo.import!(record, context, options)
           rescue e ->
             Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           catch
             :exit, e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
             e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           end
         end
       )
  end

  def import!(Jetzy.Offer, page, context, options) do
    query = from u in JetzySchema.MSSQL.Reward.Offer.Table,
                 where: 1 == 1,
                 limit: 250,
                 offset: ^((page - 1) * 250),
                 order_by: [desc: u.id]
    JetzySchema.MSSQL.Repo.all(query)
    |> Enum.map(
         fn(record) ->
           try do
             Jetzy.Offer.Repo.import!(record, context, options)
           rescue e ->
             Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           catch
             :exit, e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
             e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           end
         end
       )
  end


  def import!({Jetzy.User.Location.History, :current}, page, context, options) do
    query = from u in JetzySchema.MSSQL.User.Geo.Location.Table,
                 where: 1 == 1,
                 limit: 250,
                 offset: ^((page - 1) * 250),
                 order_by: u.id
    JetzySchema.MSSQL.Repo.all(query)
    |> Enum.map(
         fn(record) ->
           try do
             Jetzy.User.Location.History.Repo.import!(record, context, options)
           rescue e ->
             Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           catch
             :exit, e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
             e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           end
         end
       )
  end


  def import!({Jetzy.User.Location.History, :log}, page, context, options) do
    query = from u in JetzySchema.MSSQL.User.Geo.Location.Log.Table,
                 where: 1 == 1,
                 limit: 250,
                 offset: ^((page - 1) * 250),
                 order_by: u.id
    JetzySchema.MSSQL.Repo.all(query)
    |> Enum.map(
         fn(record) ->
           try do
             Jetzy.User.Location.History.Repo.import!(record, context, options)
           rescue e ->
             Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           catch
             :exit, e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
             e -> Logger.error("Exception Raised #{Exception.format(:error, e, __STACKTRACE__)}")
           end
         end
       )
  end
  
  

  def import_all!(type, context, options \\ nil, page \\ 1)
  def import_all!(Jetzy.User.Notification.Type, context, options, page) do
    query = from u in JetzySchema.MSSQL.Notification.Type.Table, where: 1 == 1
    Enum.map(JetzySchema.MSSQL.Repo.all(query), fn(record) ->
      ref = {:ref, Jetzy.User.Notification.Type.Entity, Jetzy.User.Notification.Type.Repo.legacy_enum_to_atom(record.id)}
      cond do
        Jetzy.TanbitsResolution.Repo.tanbits_by_ref!(Data.Schema.NotificationType, ref, context, options) -> {:error, :already_imported}
        :else ->
          record = %Data.Schema.NotificationType{
            description: record.description,
            message: record.description,
            event: record.description,
            inserted_at: record.created_on,
            updated_at: record.modified_on || record.created_on,
            deleted_at: record.deleted && (record.modified_on || record.created_on) || nil,
            is_deleted: record.deleted
          }
          {:ok, record} = Data.Repo.upsert(record)

          # Insert Guid for lookup.
          Jetzy.TanbitsResolution.Repo.insert_guid!(ref, Data.Schema.NotificationType, record.id, context, options)
          record
      end
    end)
  end


  def import_all!(Jetzy.User.Location.History = type, context, options, page) do
    options = update_in(options || [], [:import_tanbits], &(&1 != false && true))
  
    case import!({type, :current}, page, context, options) do
      [] -> :fin
      v when is_list(v) -> import_all!(type, context, options, page + 1)
    end

    #    case import!({type, :log}, page, context, options) do
    #      [] -> :fin
    #      v when is_list(v) -> import_all!(type, context, options, page + 1)
    #    end
  end
  
  def import_all!(type, context, options, page) do
    case import!(type, page, context, options) do
      [] -> :fin
      v when is_list(v) -> import_all!(type, context, options, page + 1)
    end
  end



end
