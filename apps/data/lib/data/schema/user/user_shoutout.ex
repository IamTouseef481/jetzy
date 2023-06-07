defmodule Data.Schema.UserShoutout do
  @moduledoc """
    The schema for User shoutout
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        description: String.t | nil,
        image_extn: String.t | nil,
        image_identifier: integer | nil,
        image_name: String.t | nil,
        blur_hash: String.t | nil,
        is_image_sync: boolean,
        is_deleted: boolean,
        is_shared: boolean,
        latitude: float,
        longitude: float,
        is_old_moment: boolean,
        shoutout_guid: String.t | nil,
        title: String.t | nil,
        updated_by: String.t | nil,
        user_id: binary,
        shoutout_type_id: binary,
        post_type_id: binary,
    }

  @required_fields ~w|
    user_id
  |a

  @optional_fields ~w|
    deleted_at
    shoutout_guid
    shoutout_type_id
    title
    description
    latitude
    longitude
    image_name
    image_extn
    is_shared
    is_deleted
    is_image_sync
    updated_by
    post_type_id
    is_old_moment
    inserted_at
    updated_at
    blur_hash
    image_identifier
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_shoutouts" do
    field :description, :string
    field :image_extn, :string
    field :image_name, :string
    field :blur_hash, :string
    field :is_image_sync, :boolean
    field :is_deleted, :boolean
    field :is_shared, :boolean
    field :latitude, :float
    field :longitude, :float
    field :is_old_moment, :boolean
    field :shoutout_guid, :string
    field :title, :string
    field :updated_by, :string
    field :image_identifier, :integer
    belongs_to :user, Data.Schema.User
    belongs_to :shoutout_type, Data.Schema.ShoutoutType
    belongs_to :post_type, Data.Schema.UserPostType

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:shoutout_type_id)
    |> foreign_key_constraint(:post_type_id)
  end

  @nmid_index 588
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
