defmodule Data.Context.EventEmails do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.EventEmail

  @spec preload_all(EventEmail.t()) :: EventEmail.t()
  def preload_all(data), do: Repo.preload(data, [])

end
