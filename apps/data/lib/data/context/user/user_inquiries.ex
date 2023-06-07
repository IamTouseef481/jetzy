defmodule Data.Context.UserInquiries do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserInquiry

  @spec preload_all(UserInquiry.t()) :: UserInquiry.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

end
