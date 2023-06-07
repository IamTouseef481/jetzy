defmodule Data.Context.MailContentSettings do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.MailContentSetting

  @spec preload_all(MailContentSetting.t()) :: MailContentSetting.t()
  def preload_all(data), do: Repo.preload(data, [])

end
