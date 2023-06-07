defmodule Data.Schema.Career do
  @moduledoc """
    The schema for Career
  """
  use Data.Schema

  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
        id: binary,
        deleted_at: DateTime.t | nil,
        applicant_city: String.t | nil,
        applicant_country: String.t | nil,
        applicant_state: String.t | nil,
        area_interest: String.t | nil,
        cover_letter: String.t | nil,
        dowant_travel: integer,
        email_address: String.t | nil,
        features_you_like: String.t | nil,
        graduation_date: :date,
        hear_about_us: String.t | nil,
        hear_about_us_textbox: String.t | nil,
        hobbies: String.t | nil,
        is_android_ios: boolean,
        is_coolandapealing: boolean,
        is_deleted: boolean,
        is_downloaded: boolean,
        is_fast: boolean,
        is_intitutiveand_easy: boolean,
        job_type: String.t | nil,
        major: String.t | nil,
        name: String.t | nil,
        phone_number: String.t | nil,
        referal_code: String.t | nil,
        resume: String.t | nil,
        school: String.t | nil,
        suggestion: String.t | nil,
        why_applying: String.t | nil,
        why_fit_for_position: String.t | nil,
        work_type: String.t | nil,
        
    }

  @required_fields ~w|
    
  |a

  @optional_fields ~w|
    deleted_at
    name
    email_address
    phone_number
    school
    major
    graduation_date
    resume
    cover_letter
    is_downloaded
    referal_code
    is_android_ios
    is_intitutiveand_easy
    is_fast
    is_coolandapealing
    dowant_travel
    features_you_like
    suggestion
    why_applying
    why_fit_for_position
    hobbies
    is_deleted
    job_type
    work_type
    area_interest
    applicant_country
    applicant_state
    applicant_city
    hear_about_us
    hear_about_us_textbox
    inserted_at
    updated_at
  |a

  @all_fields @required_fields ++ @optional_fields

  
  schema "careers" do
    field :applicant_city, :string
    field :applicant_country, :string
    field :applicant_state, :string
    field :area_interest, :string
    field :cover_letter, :string
    field :dowant_travel, :integer
    field :email_address, :string
    field :features_you_like, :string
    field :graduation_date, :date
    field :hear_about_us, :string
    field :hear_about_us_textbox, :string
    field :hobbies, :string
    field :is_android_ios, :boolean
    field :is_coolandapealing, :boolean
    field :is_deleted, :boolean
    field :is_downloaded, :boolean
    field :is_fast, :boolean
    field :is_intitutiveand_easy, :boolean
    field :job_type, :string
    field :major, :string
    field :name, :string
    field :phone_number, :string
    field :referal_code, :string
    field :resume, :string
    field :school, :string
    field :suggestion, :string
    field :why_applying, :string
    field :why_fit_for_position, :string
    field :work_type, :string


    timestamp()
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields)
    |> validate_required(@required_fields)
  end

  @nmid_index 506
  use Data.Schema.TanbitsEntity, sref: "t-career"
end
