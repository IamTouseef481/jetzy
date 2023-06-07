defmodule JetzySchema.PG.User.Table do
  @moduledoc """
  table defined in  liquibase/1.0/004_accounts_and_credentials.xml
  """
  use Ecto.Schema
  require JetzySchema.NoizuTableBehaviour

  JetzySchema.NoizuTableBehaviour.entity_table(:vnext_user)

  @primary_key {:identifier, Ecto.UUID, autogenerate: false}
  @derive {Phoenix.Param, key: :identifier}
  schema "vnext_user" do
    field :name, JetzySchema.Types.VersionedName.Reference

    field :profile_image, JetzySchema.Types.Entity.Image.Reference

    field :about, JetzySchema.Types.UserAboutVersionedString.Reference
    field :bio, JetzySchema.Types.UserBioVersionedString.Reference
    field :panic, JetzySchema.Types.UserPanicVersionedString.Reference

    field :employer, JetzySchema.Types.Employer.Reference
    field :vocation, JetzySchema.Types.Vocation.Reference
    field :school, JetzySchema.Types.School.Reference
    field :degree, JetzySchema.Types.Degree.Reference

    field :email, :string
    field :gender, JetzySchema.Types.Gender.Enum
    field :date_of_birth, :utc_datetime
    field :origin, JetzySchema.Types.Origin.Source.Enum
    field :verified, :boolean
    field :status, JetzySchema.Types.Status.Enum
    field :moderation_status, JetzySchema.Types.Moderation.Status.Enum
    field :flagged, JetzySchema.Types.Content.Flag.Enum

    #  Standard Time Stamps
    field :created_on, :utc_datetime
    field :modified_on, :utc_datetime
    field :deleted_on, :utc_datetime
  end
end
