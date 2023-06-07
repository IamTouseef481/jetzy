defmodule Data.Context.ReportSources do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.ReportSource

  @spec preload_all(ReportSource.t()) :: ReportSource.t()
  def preload_all(data), do: Repo.preload(data, [])

end
