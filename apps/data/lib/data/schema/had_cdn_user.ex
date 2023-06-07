defmodule Data.Schema.HadCdnUser do
  @moduledoc """
    The schema for Had cdn user
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        user_id: binary
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    user_id
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "had_cdn_users" do

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
  @nmid_index 596
  use Data.Schema.TanbitsEntity, sref: "t-user"

end
