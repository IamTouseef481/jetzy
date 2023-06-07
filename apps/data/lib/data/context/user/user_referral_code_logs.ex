defmodule Data.Context.UserReferralCodeLogs do

  import Ecto.Query, warn: false

  alias Data.Repo
  alias Data.Context
  alias Data.Schema.UserReferralCodeLog

  def get_referral_and_user_id_from_referral_code(referral_code) do
    UserReferralCodeLog
    |> where([q], q.referral_code == ^referral_code)
    |> select([q], %{referral_code: q.referral_code, user_id: q.user_id})
    |> Repo.one()
  end
end
