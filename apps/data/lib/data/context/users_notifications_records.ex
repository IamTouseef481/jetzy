defmodule Data.Context.UsersNotificationsRecords do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UsersNotificationsRecord

  @spec preload_all(UsersNotificationsRecord.t()) :: UsersNotificationsRecord.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
