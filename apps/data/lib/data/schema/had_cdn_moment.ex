defmodule Data.Schema.HadCdnMoment do
  @moduledoc """
    The schema for Had cdn moment
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        moment_id: binary,
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    moment_id
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "had_cdn_moments" do

    belongs_to :moment, Data.Schema.UserMoment

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
  @nmid_index 593
  use Data.Schema.TanbitsEntity, sref: "t-user"

end
