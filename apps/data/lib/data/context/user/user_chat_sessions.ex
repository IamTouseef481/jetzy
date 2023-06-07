defmodule Data.Context.UserChatSessions do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserChatSession

  @spec preload_all(UserChatSession.t()) :: UserChatSession.t()
  def preload_all(data), do: Repo.preload(data, [:first_user, :second_user, ])

end
