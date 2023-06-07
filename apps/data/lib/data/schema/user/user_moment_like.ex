defmodule Data.Schema.UserMomentLike do
  @moduledoc """
    The schema for User moment like
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        is_liked: boolean,
        user_id: binary,
        moment_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    moment_id
    is_liked
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_moment_likes" do
    field :is_liked, :boolean

    belongs_to :user, Data.Schema.User
    belongs_to :moment, Data.Schema.UserMoment

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 570
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
