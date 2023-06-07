defmodule Data.Schema.UserInterestMeta do
  @moduledoc """
    The schema for UserInterestMeta
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @required_fields ~w|

  |a

  @optional_fields ~w|
    total_members
    last_member_joined_at
    last_message_at
    interest_id
    inserted_at
    updated_at
  |a

  @all_fields @required_fields ++ @optional_fields

  schema "user_interest_meta" do
    field :total_members, :integer, default: 0
    field :last_member_joined_at, :utc_datetime
    field :last_message_at, :utc_datetime
    belongs_to :interest, Data.Schema.Interest

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end
  @nmid_index 600
  use Data.Schema.TanbitsEntity, sref: "t-user"

end
