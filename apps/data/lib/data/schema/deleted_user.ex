defmodule Data.Schema.DeletedUser do
   @moduledoc """
    The schema for User
  """
  use Data.Schema
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               deleted_at: DateTime.t | nil,
               is_deleted: boolean,
               email: String.t | nil,
               social_id: String.t | nil,
               quick_blox_id: String.t | nil,
               image_name: String.t | nil,
               current_city: String.t | nil,
               last_name: String.t | nil,
               gender: String.t | nil,
               login_type: String.t | nil,
               first_name: String.t | nil,
               home_town_city: String.t | nil,
               longitude: float,
               school: String.t | nil,
               password: String.t | nil,
               current_country: String.t | nil,
               dob: :date,
               age: integer,
               language: String.t | nil,
               is_selfie_verified: boolean | false,
               user_verification_image: String.t | nil,
               is_referral: boolean,
               dob_full: String.t | nil,
               is_email_verified: boolean,
               referral_code: String.t | nil,
               is_deactivated: boolean,
               latitude: float,
               panic_message: String.t | nil,
               user_about: String.t | nil,
               home_town_country: String.t | nil,
               quick_blox_password: String.t | nil,
               is_active: boolean | false,
               friend_code: String.t | nil,
               verification_token: String.t | nil,
               employer:  String.t | nil,
               blur_hash: String.t | nil,
               image_identifier: integer | nil,
               small_image_name: String.t | nil,
               shareable_link: String.t,
               direct_login_link: String.t,
               is_self_deactivated: boolean,
               user_id: Ecto.UUID
             }

  @required_fields ~w|
  user_id
  |a

  @optional_fields ~w|
    deleted_at
    first_name
    last_name
    email
    gender
    dob
    password
    is_deactivated
    home_town_city
    home_town_country
    user_about
    login_type
    panic_message
    quick_blox_id
    social_id
    is_email_verified
    current_city
    current_country
    image_name
    quick_blox_password
    referral_code
    is_referral
    is_active
    friend_code
    is_deleted
    dob_full
    school
    latitude
    longitude
    age
    language
    is_selfie_verified
    user_verification_image
    verification_token
    employer
    blur_hash
    small_image_name
    shareable_link
    direct_login_link
    image_identifier
    is_self_deactivated
  |a

  @all_fields @required_fields ++ @optional_fields


  schema "deleted_users" do
    field :is_deleted, :boolean
    field :email, :string, unique: true
    field :social_id, :string
    field :quick_blox_id, :string
    field :image_name, :string
    field :current_city, :string
    field :last_name, :string
    field :gender, :string
    field :login_type, :string
    field :first_name, :string
    field :home_town_city, :string
    field :longitude, :float
    field :school, :string
    field :password, :string
    field :current_country, :string
    field :dob, :utc_datetime
    field :age, :integer
    field :language, :string
    field :is_selfie_verified, :boolean, default: false, null: false
    field :user_verification_image, :string
    field :is_referral, :boolean
    field :is_active, :boolean, default: false, null: false
    field :dob_full, :string
    field :is_email_verified, :boolean
    field :referral_code, :string, unique: true
    field :is_deactivated, :boolean
    field :latitude, :float
    field :panic_message, :string
    field :user_about, :string
    field :home_town_country, :string
    field :quick_blox_password, :string
    field :friend_code, :string
    field :verification_token, :string
    field :employer, :string
    field :blur_hash, :string
    field :shareable_link, :string
    field :direct_login_link, :string
    field :small_image_name, :string
    field :image_identifier, :integer
    field :is_self_deactivated, :boolean
    belongs_to :user, Data.Schema.User

    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email)
    |> unique_constraint(:referral_code, name: :users_referral_code_index)
  end

  @nmid_index 1049
  use Data.Schema.TanbitsEntity, sref: "t-deleted-user"
end
