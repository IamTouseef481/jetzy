defmodule Data.Schema.UserVerificationRequest do
  @moduledoc """
    The schema for User Verification Requests
  """
  use Data.Schema
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  
  @type t :: %__MODULE__{
               id: binary,
               user: Data.Schema.User.t,

               approval_status: atom,
  
               social_links: String.t,
               email: String.t,
               mobile: String.t,
               contact_preference: atom,
               contact_note: String.t,
               blurb: String.t,
               first_name: String.t,
               last_name: String.t,
               middle_names: String.t,
               
               more_details: String.t,
               internal_staff_note: String.t,
               staff_note: String.t,
  
               inserted_at: DateTime.t,
               updated_at: DateTime.t,
               deleted_at: DateTime.t | nil,
             }
  
  @generated_fields ~w|
  
  |a
  
  @joined_fields ~w|
  
  |a
  
  @required_fields ~w|
  user_id
  approval_status
  updated_at
  inserted_at
  |a

  @optional_fields ~w|
  social_links
  email
  mobile
  contact_preference
  contact_note
  blurb
  first_name
  last_name
  middle_names
  more_details
  internal_staff_note
  staff_note
  deleted_at
  |a
  
  @all_fields @required_fields ++ @optional_fields
  
  
  schema "user_verification_requests" do
    has_one :user, Data.Schema.User
    field :approval_status, Ecto.Enum, values: [:approved, :pending, :paused, :denied, :review], null: false
    field :social_links, :string
    field :email, :string,  redact: true
    field :mobile, :string,  redact: true
    field :contact_preference, Ecto.Enum, values: [:mobile, :email, :in_app]
    field :contact_note, :string
    field :blurb, :string
    field :first_name, :string
    field :last_name, :string
    field :middle_names, :string
    field :more_details, :string
    field :internal_staff_note, :string, redact: true
    field :staff_note, :string
    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields -- @generated_fields)
    |> validate_required(@required_fields)
  end
  
  @nmid_index 1050
  use Data.Schema.TanbitsEntity, sref: "t-user-verification-request"
end