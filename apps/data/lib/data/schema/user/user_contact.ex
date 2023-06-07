defmodule Data.Schema.UserContact do
  @moduledoc """
    The schema for User filter
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        first_name: String.t | nil,
        last_name: String.t | nil,
        email: String.t | nil,
        mobile: String.t | nil,
        user_id: binary
    }

  @required_fields ~w|
    user_id
  |a

  @optional_fields ~w|
    email
    mobile
    created_on
    modified_on
    deleted_on
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "user_contacts" do
    field :email, :string
    field :mobile, :string
    field :first_name, :string
    field :last_name, :string

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> require_email_or_mobile()
  end

  @nmid_index 618
  use Data.Schema.TanbitsEntity, sref: "t-user"
  
  defp require_email_or_mobile(changeset) do
    with %Ecto.Changeset{valid?: true} <- changeset,
          true <- is_nil(get_field(changeset, :mobile)) && is_nil(get_field(changeset, :email)) do
        changeset
        |> add_error(:email, "One of Email or Mobile field is required")
        |> add_error(:mobile, "One of Email or Mobile field is required")
    else
      _ -> changeset
    end
  end
end
