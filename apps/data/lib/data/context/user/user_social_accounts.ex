defmodule Data.Context.UserSocialAccounts do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.UserSocialAccount

  @spec preload_all(UserSocialAccount.t()) :: UserSocialAccount.t()
  def preload_all(data), do: Repo.preload(data, [:user, ])

  def query_by_social_network_and_id(social_network, social_account_id) when social_network in ~w(facebook apple google)a do
    # String to atom
    social_network = to_string(social_network)

    from(
      c in UserSocialAccount,
      where: c.type == ^social_network and
             c.external_id == ^social_account_id,
      preload: :user
    ) |> Repo.one()
  end
end
