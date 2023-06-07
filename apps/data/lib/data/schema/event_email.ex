defmodule Data.Schema.EventEmail do
  @moduledoc """
    The schema for Event email
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        date: String.t | nil,
        mail_from: String.t | nil,
        mail_to: String.t | nil,

    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    mail_to
    mail_from
    date
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "event_emails" do
    field :date, :string
    field :mail_from, :string
    field :mail_to, :string


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 514
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
