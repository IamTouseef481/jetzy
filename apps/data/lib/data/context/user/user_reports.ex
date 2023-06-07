defmodule Data.Context.UserReports do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserReport

  @spec preload_all(UserReport.t()) :: UserReport.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
