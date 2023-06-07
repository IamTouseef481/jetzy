defmodule Data.Context.UserReferrals do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.{UserReferral, User, UserReferralCodeLog}
  alias Data.Context.{UserReferrals, Users}
  
  @spec preload_all(UserReferral.t()) :: UserReferral.t()
  def preload_all(data), do: Repo.preload(data, [:referred_from])

  
  def verify(email, code) when is_bitstring(code) do
      case UserReferrals.check_record(email, code) do
        %UserReferral{is_accept: true} = ref -> {:ok, {:accepted, ref}}
        %UserReferral{} = ref -> {:ok, {:invite, ref}}
        _ ->
          case get_referral_code_owner(code) do
            user = %{id: id} -> {:ok, {:new, user}}
            _ -> {:error, :not_found}
          end
      end
  end
  def verify(_, _), do: {:error, :not_provided}


  def get_referral_code_owner(referral_code) do
    res = User
          |> where([u], u.referral_code == ^referral_code)
          |> select([u], %{id: u.id})
          |> Repo.one()
    if is_nil(res) do
      UserReferralCodeLog
      |> where([q], q.referral_code == ^referral_code)
      |> select([q], %{id: q.user_id})
      |> Repo.one()
    else
      res
    end
  end
  
  
  def get_by(referred_to, user_id) do
    UserReferral
    |> where([u], u.referred_to == ^referred_to and u.referred_from_id == ^user_id)
    |> Repo.one()
  end

  def get_referral_count_by_user(user_id) do
    UserReferral
    |> where([u], u.referred_from_id == ^user_id)
    |> select([u], count(u.id))
    |> Repo.one()
  end
  def is_exist_referral_code(referral_code) do
    UserReferral
    |> where([ur], ur.referral_code == ^ referral_code)
    |> Repo.one()
  end
  def check_record(nil, _), do: nil
  def check_record(email, referral_code) do
    UserReferral
    |> where([ur], ur.referral_code == ^referral_code and ur.referred_to == ^email)
    |> Repo.one()
  end

  def get_reffered_users_by_user_id(user_id, page, page_size \\ 20)do
    UserReferral
    |> join(:inner, [ur], u in  User, on: u.id == ur.referred_from_id )
    |> join(:inner, [ur2], u2 in  User, on: u2.email == ur2.referred_to )
    |> where([ur], ur.referred_from_id == ^user_id and ur.is_accept == true)
    |> select([..., u2], %{id: u2.id, first_name: u2.first_name, last_name: u2.last_name,
      email: u2.email, small_image_name: u2.small_image_name, is_active: u2.is_active,
      blur_hash: u2.blur_hash, age: u2.age, image_name: u2.image_name})
    |> Repo.paginate(%{page: page, page_size: page_size})
  end



  def check_is_refferal_by_email__cache_key(email) do
    {:check_is_refferal_by_email, email}
  end

  def check_is_refferal_by_email__clear_cache(email) do
    key = check_is_refferal_by_email__cache_key(email)
    ConCache.delete(ConCache.Resident, key)
  end

  def check_is_refferal_by_email__cached(nil), do: nil
  def check_is_refferal_by_email__cached(email) do
    key = check_is_refferal_by_email__cache_key(email)
    ConCache.get_or_store(ConCache.Resident, key, fn() ->
      i = UserReferral
          |> where([ur], ur.referred_to == ^email and ur.is_accept == true)
          |> select([ur], %{is_accept: ur.is_accept})
          |> Repo.one()
      {:ok, i}
    end) |> case do
              {:ok, v} -> v
              _ -> nil
            end
  end
  
  
  def check_is_refferal_by_email(nil), do: nil
  def check_is_refferal_by_email(email) do
    UserReferral
    |> where([ur], ur.referred_to == ^email and ur.is_accept == true)
    |> select([ur], %{is_accept: ur.is_accept})
    |> Repo.one()
  end

  def get_no_of_referrals(user_id) when not is_nil(user_id) do
    UserReferral
    |> where([ur], ur.referred_from_id == ^user_id )
    |> where([ur], ur.is_accept == true)
    |> select([ur], count(ur.id))
    |> Repo.one()
  end
  def get_no_of_referrals(_), do: nil

  def delete_referrals_by_user(%User{} = user) do
    UserReferral
    |> where([ur], ur.referred_from_id == ^user.id or ur.referred_to == ^user.email)
    |> where([ur], not is_nil(ur.deleted_at))
    |> Repo.update_all([set: [deleted_at: DateTime.utc_now()]])
  end

end
