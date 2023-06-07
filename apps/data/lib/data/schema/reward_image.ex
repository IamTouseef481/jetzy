defmodule Data.Schema.RewardImage do
  @moduledoc """
    The schema for Reward image
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        image_name: String.t | nil,
               image_identifier: integer | nil,
        small_image_name: String.t | nil,
        blur_hash: String.t,
        reward_offer_id: binary
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    small_image_name
    image_name
    reward_offer_id
    inserted_at
    updated_at
    image_identifier
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "reward_images" do
    field :image_name, :string
    field :small_image_name, :string
    field :blur_hash, :string
    field :image_identifier, :integer
    belongs_to :reward_offer, Data.Schema.RewardOffer

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:reward_offer_id)
  end

  @nmid_index 532
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
