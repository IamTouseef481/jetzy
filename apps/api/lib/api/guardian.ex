defmodule Api.Guardian do
    use Guardian, otp_app: :api

    def subject_for_token(%{} = resource, _claims) do
      sub = to_string(resource.id)
      {:ok, sub}
    end

    def subject_for_token(_, _) do
      {:error, :reason_for_error}
    end

    def resource_from_claims(%{} = claims) do
      id = claims["sub"]
      case Data.Context.get(Data.Schema.User, id) do
        %Data.Schema.User{} = resource -> {:ok, resource}
        _ -> {:error, ["User does not exist"]}
      end
    end

    def resource_from_claims(_) do
      {:error, :reason_for_error}
    end
  end
