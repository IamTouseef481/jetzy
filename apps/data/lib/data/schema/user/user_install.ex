defmodule Data.Schema.UserInstall do
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol

  schema "user_installs" do
    field :device_info, :map
    field :device_token, :string
    field :fcm_token, :string
    field :os, :string
    field :current_jwt, :string
    belongs_to :user, Data.Schema.User

    timestamps()
  end

  @required_fields ~w|
  user_id
  device_token
  |a

  @optional_fields ~w|
    fcm_token
    os
    device_info
    inserted_at
    updated_at
    current_jwt

  |a

  @all_fields @required_fields ++ @optional_fields


  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  def changeset_for_update_fcm_token(user_installs, attrs) do
    user_installs
    |> cast(attrs, [:fcm_token])
    |> unique_constraint(:device_token)
  end

  @nmid_index 599
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
