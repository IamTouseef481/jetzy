defmodule Data.Context.UserLastActivityLogs do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserLastActivityLog

  @spec preload_all(UserLastActivityLog.t()) :: UserLastActivityLog.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
