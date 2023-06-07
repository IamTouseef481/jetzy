defmodule Data.Schema.UserShoutoutsPrivate do
  @moduledoc """
    The schema for User shoutouts private
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        group_id: integer,
        is_private: boolean,
        is_old_moment: boolean,
        shoutout_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    shoutout_id
    is_old_moment
    is_private
    group_id
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_shoutouts_privates" do
    field :group_id, :integer
    field :is_private, :boolean
    field :is_old_moment, :boolean

    belongs_to :shoutout, Data.Schema.UserShoutout

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 592
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
