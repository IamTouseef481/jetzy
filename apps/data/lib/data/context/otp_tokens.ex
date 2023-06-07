defmodule Data.Context.OTPTokens do
  import Ecto.Query, warn: false
  #  alias Data.Context
  
  
  def create_request(email) do
    case Data.Context.Users.get_user_by_email(email)do
      nil -> {:error, :not_found}
      %Data.Schema.User{} = user ->
        otp = number()
        case Data.Context.get_by(Data.Schema.OTPToken, user_id: user.id) do
          nil ->
            case Data.Context.create(Data.Schema.OTPToken, %{otp: otp, last_otp_sent_at: DateTime.utc_now(), user_id: user.id}) do
              {:ok, otp} -> {:ok, {user, otp}}
              v -> v
            end
          %Data.Schema.OTPToken{} = otp_token ->
            case Data.Context.update(Data.Schema.OTPToken, otp_token, %{otp: otp, last_otp_sent_at: DateTime.utc_now()}) do
              {:ok, otp} -> {:ok, {user, otp}}
              v -> v
            end
        end
    end
  end
  
  def valid_code(email, code) do
    case Data.Context.Users.get_user_by_email(email) do
      nil -> {:error, :not_found}
      %Data.Schema.User{id: user_id} = user ->
        case Data.Context.get_by(Data.Schema.OTPToken, user_id: user_id) do
          nil -> {:error, :code_not_found}
          %Data.Schema.OTPToken{otp: otp_code} = otp_token when otp_code == code ->
            {:ok, {user, otp_token}}
          _ ->
            {:error, :code_invalid}
        end
    end
  end
  

  def number(min \\ 100_000, max \\ 999_999) do
    # :rand.uniform(count)
    Enum.random(min..max)
  end
end
