defmodule Data.Schema.RewardOffer do
  @moduledoc """
    The schema for Reward offer
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        event_end_date: :date,
        event_start_date: :date,
        image_name: String.t | nil,
        image_identifier: integer | nil,
        blur_hash: String.t | nil,
        is_deleted: boolean,
        is_pinned: boolean,
        latitude: float,
        link: String.t | nil,
        location: String.t | nil,
        longitude: float,
        multi_redeem_allowed: boolean,
        offer_description: String.t | nil,
        offer_name: String.t | nil,
        pin_date: :date,
        point_required: integer,
        price_of_ticket: float,
        tier_id: Ecto.UUID,
        order: integer,
        small_image_name: String.t | nil,
        status_id: Ecto.UUID,
        shareable_link: String.t | nil,
        code: String.t | nil
    }

  @required_fields ~w|
    point_required

  |a

  @optional_fields ~w|
    deleted_at
    offer_name
    small_image_name
    blur_hash
    tier_id
    is_deleted
    offer_description
    image_name
    multi_redeem_allowed
    latitude
    longitude
    is_pinned
    event_start_date
    event_end_date
    pin_date
    price_of_ticket
    link
    order
    shareable_link
    location
    status_id
    inserted_at
    updated_at
    image_identifier
    code
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "reward_offers" do
    field :event_end_date, :date
    field :event_start_date, :date
    field :image_name, :string
    field :blur_hash, :string
    field :is_deleted, :boolean
    field :is_pinned, :boolean
    field :latitude, :float
    field :link, :string
    field :location, :string
    field :longitude, :float
    field :multi_redeem_allowed, :boolean
    field :offer_description, :string
    field :offer_name, :string
    field :pin_date, :date
    field :point_required, :integer
    field :order, :integer
    field :price_of_ticket, :float
    field :small_image_name, :string
    field :shareable_link, :string
    field :image_identifier, :integer
    field :code, :string

    belongs_to :tier, Data.Schema.RewardTier
    belongs_to :status, Data.Schema.Status
    has_many :reward_images, Data.Schema.RewardImage
    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 534
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
