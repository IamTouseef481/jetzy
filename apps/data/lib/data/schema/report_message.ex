defmodule Data.Schema.ReportMessage do
  @moduledoc """
    The schema for Report message
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        report_source_id: String.t(),
        is_deleted: boolean
    }

  @required_fields ~w|

    report_source_id
    user_id
    item_id
    description
  |a

  @optional_fields ~w|
    deleted_at
    inserted_at
    updated_at
    is_deleted
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "report_messages" do

    belongs_to :report_source, Data.Schema.ReportSource, type: :string
    belongs_to :user, Data.Schema.User
    field :description, :string
    field :item_id, :binary_id
    field :is_deleted, :boolean

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 1030
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
