defmodule Data.Schema.UserShoutoutsImage do
  @moduledoc """
    The schema for User shoutouts image
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        image_identifier: integer | nil,
        shoutout_images: String.t | nil,
        shoutout_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    shoutout_id
    shoutout_images
    inserted_at
    updated_at
    image_identifier
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_shoutouts_images" do
    field :shoutout_images, :string
    field :image_identifier, :integer
    belongs_to :shoutout, Data.Schema.UserShoutout

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 591
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
