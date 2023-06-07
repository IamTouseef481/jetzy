defmodule Data.Schema.InviteFriendRequest do
  @moduledoc """
    The schema for Invite friend request
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        contact_number: String.t | nil,
        created_date: :date,
        emails: String.t | nil,
        first_name: String.t | nil,
        friends_email: String.t | nil,
        last_modified_date: :date,
        last_name: String.t | nil,
        request_code: String.t | nil,
        user_id: binary
    }

  @required_fields ~w|

  |a

  @optional_fields ~w|
    deleted_at
    emails
    contact_number
    user_id
    friends_email
    request_code
    created_date
    last_modified_date
    first_name
    last_name
    inserted_at
    updated_at

  |a

  @all_fields @required_fields ++ @optional_fields


  schema "invite_friend_requests" do
    field :contact_number, :string
    field :created_date, :date
    field :emails, :string
    field :first_name, :string
    field :friends_email, :string
    field :last_modified_date, :date
    field :last_name, :string
    field :request_code, :string

    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 518
  use Data.Schema.TanbitsEntity, sref: "t-user"
end
