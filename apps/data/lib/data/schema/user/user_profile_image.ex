defmodule Data.Schema.UserProfileImage do
  @moduledoc """
    The schema for User profile image
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        created_date: :date,
        image_identifier: integer | nil,
        image_name: String.t | nil,
        is_current: boolean,
        last_modified_date: :date,
        small_image_name: String.t | nil,
        blur_hash: String.t | nil,
        user_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    image_name
    small_image_name
    is_current
    created_date
    last_modified_date
    inserted_at
    updated_at
    blur_hash
    image_identifier
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_profile_images" do
    field :created_date, :date
    field :image_name, :string
    field :is_current, :boolean
    field :last_modified_date, :date
    field :small_image_name, :string
    field :blur_hash, :string
    field :image_identifier, :integer
    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 578
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
