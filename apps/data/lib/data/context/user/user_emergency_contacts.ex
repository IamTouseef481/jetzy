defmodule Data.Context.UserEmergencyContacts do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserEmergencyContact

  @spec preload_all(UserEmergencyContact.t()) :: UserEmergencyContact.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
