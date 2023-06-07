defmodule Data.Schema.MailContentSetting do
  @moduledoc """
    The schema for Mail content setting
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        bcc: String.t | nil,
        body_text: String.t | nil,
        description: String.t | nil,
        from: String.t | nil,
        is_active: boolean,
        subject: String.t | nil,

    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    subject
    body_text
    description
    from
    bcc
    is_active
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "mail_content_settings" do
    field :bcc, :string
    field :body_text, :string
    field :description, :string
    field :from, :string
    field :is_active, :boolean
    field :subject, :string


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 521
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
