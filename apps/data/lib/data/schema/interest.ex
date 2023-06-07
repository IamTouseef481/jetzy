defmodule Data.Schema.Interest do
  @moduledoc """
    The schema for Interest
  """
  use Data.Schema
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               deleted_at: DateTime.t | nil,
               background_colour: String.t | nil,
               description: String.t | nil,
               image_name: String.t | nil,
               blur_hash: String.t | nil,
               interest_name: String.t | nil,
               is_deleted: boolean,
               is_group_private: boolean,
               is_private: boolean,
               small_image_name: String.t | nil,
               status: boolean,
               created_by_id: binary,
               popularity_score: integer | 0,
               image_identifier: integer | nil,
               shareable_link: String.t | nil
                                                              }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    interest_name
    description
    status
    background_colour
    image_name
    blur_hash
    is_private
    small_image_name
    is_deleted
    is_group_private
    popularity_score
    inserted_at
    updated_at
    created_by_id
    image_identifier
    shareable_link
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "interests" do
    field :background_colour, :string
    field :description, :string
    field :image_identifier, :integer
    field :image_name, :string
    field :blur_hash, :string
    field :interest_name, :string
    field :is_deleted, :boolean
    field :is_group_private, :boolean
    field :is_private, :boolean
    field :small_image_name, :string
    field :status, :boolean, default: true
    field :popularity_score, :integer, default: 0
    field :shareable_link, :string
    #used to order by in query
    field :ordering_variable, :string, virtual: true

    belongs_to :created_by, Data.Schema.User
    has_many :interest_topics, Data.Schema.InterestTopic, on_replace: :delete
    has_one :user_interest_meta, Data.Schema.UserInterestMeta

    has_many :user_events, Data.Schema.UserEvent
    many_to_many :user_interests, Data.Schema.User, join_through: "user_interests"

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 517
  use Data.Schema.TanbitsEntity, sref: "t-interest"

end
