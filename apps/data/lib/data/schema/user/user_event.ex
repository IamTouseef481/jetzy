defmodule Data.Schema.UserEvent do
    @moduledoc """
      The schema for User event
    """
    use Data.Schema

    @derive Noizu.ERP
  @derive Tanbits.Shim
    @derive Noizu.EctoEntity.Protocol
    @type t :: %__MODULE__{
          id: binary,
          deleted_at: DateTime.t | nil,
          description: String.t | nil,
          image: String.t | nil,
          image_identifier: integer | nil,
          formatted_address: String.t | nil,
          event_start_date: :date,
          event_end_date: :date,
          event_start_time: :time,
          event_end_time: :time,
          latitude: float,
          longitude: float,
          user_id: binary,
          interest_id: binary,
          room_id: binary,
          group_chat_room_id: binary,
          post_type: String.t | nil,
          blur_hash: String.t | nil,
          small_image: String.t | nil,
          shareable_link_feed: String.t | nil,
          shareable_link_event: String.t | nil
        }

    @required_fields ~w|

    |a

    @optional_fields ~w|
      user_id
      interest_id
      room_id
      description
      group_chat_room_id
      latitude
      longitude
      formatted_address
      event_start_date
      event_end_date
      event_start_time
      event_end_time
      image
      inserted_at
      updated_at
      post_type
      blur_hash
      small_image
      shareable_link_feed
      shareable_link_event
      post_tags
      post_email_tags
      image_identifier
    |a

    @all_fields @required_fields ++ @optional_fields


    schema "user_events" do
        field :description, :string
        field :event_end_date, :date
        field :event_start_date, :date
        field :formatted_address, :string
        field :latitude, :float
        field :longitude, :float
        field :image, :string
        field :event_start_time, :time
        field :event_end_time, :time
        field :post_type, Ecto.Enum, values: [:activity, :post, :question, :recommendation, :moment]
        field :blur_hash, :string
        field :small_image, :string
        field :shareable_link_feed, :string
        field :shareable_link_event, :string
        field :post_tags, {:array, :string}
        field :image_identifier, :integer
        field :post_email_tags, {:array, :string}


        field :rank, :integer, virtual: true
        #used to make slabs of distance
        field :distance_slab, :integer, virtual: true
        field :distance, :integer, virtual: true
        field :distance_unit, :string, virtual: true
        #used in view. preload will fill it
        field :interest_name, :string, virtual: true
        #vitual field to sort posts from followed at top
        field :followership, :string, virtual: true

      belongs_to :user, Data.Schema.User
      belongs_to :interest, Data.Schema.Interest
      belongs_to :room, Data.Schema.Room
      belongs_to :group_chat_room, Data.Schema.Room, foreign_key: :group_chat_room_id

      has_many :user_event_images, Data.Schema.UserEventImage

      timestamp()
    end

    def changeset(model, params \\ %{}) do
      model
      |> cast(params, @all_fields)
      |> validate_required(@required_fields)
    end

    @nmid_index 553
    use Data.Schema.TanbitsEntity, sref: "t-user-event"
  end
