defmodule Data.Schema.ApiUserActivityLog do
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  schema "api_user_activity_logs" do
    field :api_token, :string
    field :api_version, :integer
    field :app_version, :string
    field :device_id, :string
    field :device_type, :integer
    field :end_point, :string
    field :error_class, :string
    field :error_code, :string
    field :error_description, :string
    field :old_user_id, :string
    field :request_content, :string
    field :when, :utc_datetime

    belongs_to :user, Data.Schema.User

    timestamps()
  end

  @required_fields ~w|

  |a

  @optional_fields ~w|
    user_id
    old_user_id
    end_point
    when
    api_token
    api_version
    request_content
    error_class
    error_code
    error_description
    device_id
    device_type
    app_version
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields

  @doc false
  def changeset(model,  params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required([])
    |> foreign_key_constraint(:user_id)
  end


  @nmid_index 505
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
