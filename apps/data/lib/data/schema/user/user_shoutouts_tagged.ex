defmodule Data.Schema.UserShoutoutsTagged do
  @moduledoc """
    The schema for User shoutouts tagged
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        contact_number: String.t | nil,
        email: String.t | nil,
        flag: boolean,
        group_id: integer,
        is_private: boolean,
        user_id: binary,
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
    user_id
    email
    contact_number
    flag
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_shoutouts_tagged" do
    field :contact_number, :string
    field :email, :string
    field :flag, :boolean
    field :group_id, :integer
    field :is_private, :boolean
    field :is_old_moment, :integer

    belongs_to :shoutout, Data.Schema.UserShoutout
    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:shoutout_id)
  end

  @nmid_index 1093
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
