defmodule Data.Schema.LikeDetail do
  @moduledoc """
    The schema for Like detail
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        item_id: integer,
        liked: boolean,
        is_old_moment: boolean,
        like_source_id: binary,
        user_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    like_source_id
    item_id
    liked
    user_id
    is_old_moment
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "like_details" do
    field :liked, :boolean
    field :is_old_moment, :boolean

    belongs_to :item, Data.Schema.UserShoutout
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

  @nmid_index 519
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
