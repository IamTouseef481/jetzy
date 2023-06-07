defmodule Data.Schema.ElmahError do
  use Data.Schema

  schema "elmah_errors" do
    field :all_xml, :string
    field :application, :string
    field :error_type, :string
    field :host, :string
    field :message, :string
    field :sequence, :integer
    field :source, :string
    field :status_code, :integer
    field :time_utc, :utc_datetime

    timestamps()
  end


  @required_fields ~w|

  |a

  @optional_fields ~w|
    application
    host
    error_type
    source
    message
    status_code
    time_utc
    sequence
    all_xml
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

end
