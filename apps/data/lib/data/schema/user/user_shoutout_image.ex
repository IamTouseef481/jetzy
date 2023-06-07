defmodule Data.Schema.UserShoutoutImage do
  @moduledoc """
    The schema for User shoutout image
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        image_extn: String.t | nil,
        image_name: String.t | nil,
        image_identifier: integer | nil,
        blur_hash: String.t | nil,
        is_current: boolean,
        is_deleted: boolean,
        is_image_sync: boolean,
        is_shared: boolean,
        sort_order: integer,
        shoutout_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    shoutout_id
    image_name
    image_extn
    sort_order
    is_current
    is_shared
    is_deleted
    is_image_sync
    inserted_at
    updated_at
    blur_hash
    image_identifier
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_shoutout_images" do
    field :image_extn, :string
    field :image_name, :string
    field :image_identifier, :integer
    field :blur_hash, :string
    field :is_current, :boolean
    field :is_deleted, :boolean
    field :is_image_sync, :boolean
    field :is_shared, :boolean
    field :sort_order, :integer

    belongs_to :shoutout, Data.Schema.UserShoutout

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 589
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
