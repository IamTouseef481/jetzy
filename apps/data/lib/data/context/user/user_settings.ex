defmodule Data.Context.UserSettings do
  import Ecto.Query, warn: false

  alias Data.Repo
  #  alias Data.Context
  alias Data.Schema.UserSetting

  @spec preload_all(UserSetting.t(), []) :: UserSetting.t()
  def preload_all(data, preloads \\ [:user]), do: Repo.preload(data, preloads)

end
