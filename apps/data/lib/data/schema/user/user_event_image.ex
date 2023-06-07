defmodule Data.Schema.UserEventImage do
  @moduledoc """
    The schema for User_event_image
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        image: String.t | nil,
        image_identifier: integer | nil,
        user_event_id: binary,
        blur_hash: String.t | nil,
        small_image: String.t | nil,
        deleted_at: DateTime.t | nil,

    }

  @required_fields ~w|
    image
    user_event_id
    small_image
  |a

  @optional_fields ~w|
    inserted_at
    updated_at
    deleted_at
    blur_hash
    image_identifier
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_event_images" do
    field :image, :string
    field :blur_hash, :string
    field :small_image, :string
    field :image_identifier, :integer
    belongs_to :user_event, Data.Schema.UserEvent

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 555
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
