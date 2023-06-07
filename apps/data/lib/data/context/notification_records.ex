defmodule Data.Context.NotificationsRecords do
  import Ecto.Query, warn: false

  alias Data.Repo
  alias Data.Schema.{NotificationsRecord}
  require Logger

  @spec preload_all(NotificationsRecord.t()) :: NotificationsRecord.t()
  def preload_all(data), do: Repo.preload(data, [:sender, :receiver, :moment, :shoutout, :comment, :comment_source, ])

  def get_notification_record_by_notification_id(notification_id, user_id) do
    NotificationsRecord
    |> where([nr], nr.id == ^notification_id and nr.receiver_id == ^user_id)
    |> where([nr], nr.is_read == false)
    |> Repo.one()
  end

  def get_user_notifications(current_user_id, page, page_size \\ 10) do
    NotificationsRecord
    |> where([nr], nr.receiver_id == ^current_user_id)
    |> where([nr], nr.is_deleted == false)
    |> where([nr], is_nil(nr.deleted_at))
    |> order_by([nr], [desc: nr.inserted_at])
    |> Repo.paginate(page: page, page_size: page_size)
  end

  @spec get_unread_notifications_count(any) :: any
  def get_unread_notifications_count(current_user_id) do
    NotificationsRecord
    |> where([nr], nr.receiver_id == ^current_user_id)
    |> where([nr], nr.is_opened == false)
    |> where([nr], nr.is_deleted == false)
    |> where([nr], is_nil(nr.deleted_at))
    |> select([nr], count(nr.id))
    |> Repo.one
  end

  def delete_push_notification(sender_id, receiver_id, types) do
    NotificationsRecord
    |> where([nr], nr.sender_id == ^sender_id)
    |> where([nr], nr.receiver_id == ^receiver_id)
    |> where([nr], is_nil(nr.deleted_at))
    |> where([nr], nr.type in ^types)
    |> Repo.update_all([set: [is_deleted: true, updated_at: DateTime.truncate(DateTime.utc_now(), :second),
      deleted_at: DateTime.truncate(DateTime.utc_now(), :second)]])
  end

  def update_notifications_opened_status(user_id) do
    NotificationsRecord
    |> where([nr], nr.receiver_id == ^user_id and nr.is_opened == false)
    |> Repo.update_all(set: [is_opened: true])
  end

  def delete_notification_by_receiver_and_resource_id(receiver_id, resource_id) do
    NotificationsRecord
    |> where([nr], nr.receiver_id == ^receiver_id and nr.resource_id == ^resource_id)
    |> Repo.update_all([set: [is_deleted: true, deleted_at: DateTime.truncate(DateTime.utc_now(), :second)]])
  end

  def delete_notification_by_resource_id(resource_id) do
    NotificationsRecord
    |> where([nr], nr.resource_id == ^resource_id)
    |> Repo.update_all([set: [is_deleted: true, deleted_at: DateTime.truncate(DateTime.utc_now(), :second)]])
  end

  def delete_notification_records_by_user_id(_, _, user_id) do
    try do
      NotificationsRecord
      |> where([nr], nr.sender_id == ^user_id or nr.receiver_id == ^user_id)
      |> Repo.update_all([set: [deleted_at: DateTime.utc_now, is_deleted: true]])
      {:ok, :success}
    rescue
     e  ->
       Logger.error(Exception.format(:error, e, __STACKTRACE__))
       reraise e, __STACKTRACE__
       {:error, e}
    end
  end
end
