defmodule Data.Context.RoomReferralCodes do
  import Ecto.Query, warn: false

  alias Data.Repo
  #  alias Data.Context
  alias Data.Schema.RoomReferralCode


  def is_exist_referral_code(referral_code) do
    RoomReferralCode
    |> where([ur], ur.referral_code == ^ referral_code)
    |> Repo.one()
  end

  def get_referral_code_by_room_id(room_id) do
    RoomReferralCode
    |> where([rrc], rrc.room_id == ^room_id)
    |> order_by([rrc], [desc: rrc.inserted_at])
    |> limit([rrc], 1)
    |> select([rrc], rrc.referral_code)
    |> Repo.one()
  end

end
