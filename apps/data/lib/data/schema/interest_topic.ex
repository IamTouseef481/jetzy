defmodule Data.Schema.InterestTopic do
    @moduledoc """
      The schema for Interest Topic
    """
    use Data.Schema

    @derive Noizu.ERP
  @derive Tanbits.Shim
    @derive Noizu.EctoEntity.Protocol
    @type t :: %__MODULE__{
            id: binary,
            topic_name: String.t() | nil,
            description: String.t() | nil,
            interest_id: binary,
            room_id: binary,
            image_name: String.t() | nil,
            small_image_name: String.t | nil,
            blur_hash: String.t | nil,
            created_by_id: binary,
                 image_identifier: integer | nil,
          }

    @required_fields ~w|
      interest_id

      |a

    @optional_fields ~w|
        topic_name
        room_id
        small_image_name
        description
        image_name
        created_by_id
        inserted_at
        updated_at
        image_identifier
      |a

    @updateable_fields ~w|
        topic_name
        description
        image_name
        small_image_name
        blur_hash
      |a

    @all_fields @required_fields ++ @optional_fields

    schema "interest_topics" do
      field(:topic_name, :string)
      field(:description, :string)
      field(:image_name, :string)
      field(:blur_hash, :string)
      field(:small_image_name, :string)
      field :image_identifier, :integer

      belongs_to(:interest, Data.Schema.Interest)
      belongs_to(:room, Data.Schema.Room)
      belongs_to(:created_by, Data.Schema.User)
      timestamp()
    end

    def changeset(model, params \\ %{}) do
      model
      |> cast(params, @all_fields)
      |> validate_required(@required_fields)
    end

    def update_changeset(model, params \\ %{}) do
      model
      |> cast(params, @updateable_fields)
      |> validate_required(@required_fields)
    end

    @nmid_index 595
    use Data.Schema.TanbitsEntity, sref: "t-user"
  end
