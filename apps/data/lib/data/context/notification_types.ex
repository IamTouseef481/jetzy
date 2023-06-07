defmodule Data.Context.NotificationTypes do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.NotificationType

  @spec preload_all(NotificationType.t()) :: NotificationType.t()
  def preload_all(data), do: Repo.preload(data, [])

  def get_notification_type_by_event(event) do
    NotificationType
    |> where([nt], nt.event == ^event)
    |> Repo.one()
  end

  def get_notification_type_ids do
    NotificationType
    |> select([nt], nt.id)
    |> Repo.all
  end

  def get_notification_type_id(event) do
    NotificationType
    |> where([nt], nt.event == ^event)
    |> select([nt], nt.id)
    |> Repo.one
  end

end
