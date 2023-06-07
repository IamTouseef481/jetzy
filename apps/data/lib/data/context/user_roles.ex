defmodule Data.Context.UserRoles do

  import Ecto.Query, warn: false

  alias Data.Repo
  #  alias Data.Context
  alias Data.Schema.UserRole

  def get_roles_by_user_id(user_id) do
    UserRole
    |> where([ur], ur.user_id == ^user_id)
    |> select([ur], ur.role_id)
    |> Repo.all()
  end
end