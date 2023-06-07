defmodule Data.Schema.UserEventLike do
  @moduledoc """
    The schema for UserEvent Like
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        item_id: binary,
        liked: boolean | true,
        is_old_moment: boolean | false,
        like_source_id: binary,
        user_id: binary,
    }

  @required_fields ~w|
    item_id
    user_id
  |a

  @optional_fields ~w|

    like_source_id
    liked
    is_old_moment
    inserted_at
    updated_at
    deleted_at
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_event_likes" do
    field :liked, :boolean, default: true, null: false
    field :is_old_moment, :boolean, default: false, null: false

    belongs_to :item, Data.Schema.UserEvent
    belongs_to :like_source, Data.Schema.LikeSource
    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:item_id)
    |> foreign_key_constraint(:like_source_id)
    |> foreign_key_constraint(:user_id)
  end

  @nmid_index 556
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
