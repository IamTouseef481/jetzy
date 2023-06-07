defmodule JetzySchema.MSSQL.Career.Table do
  use Ecto.Schema
  @nmid_index 7

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"Career")
  # ENTRY Career JetzySchema.MSSQL.Career.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[Career]    Script Date: 2/24/2020 9:42:56 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[Career](
  [Id] [int] IDENTITY(1,1) NOT NULL,
  [Name] [nvarchar](100) NULL,
  [EmailAddress] [nvarchar](100) NULL,
  [PhoneNumber] [nvarchar](100) NULL,
  [School] [nvarchar](100) NULL,
  [Major] [nvarchar](100) NULL,
  [GraduationDate] [date] NULL,
  [Resume] [nvarchar](200) NULL,
  [CoverLetter] [nvarchar](100) NULL,
  [Isdownloded] [bit] NULL,
  [RefferalCode] [nvarchar](100) NULL,
  [IsAndroidorIOS] [nvarchar](50) NULL,
  [IsIntitutiveandEasy] [int] NULL,
  [Isfast] [int] NULL,
  [Iscoolandapealing] [int] NULL,
  [DowantTravel] [int] NULL,
  [FeaturesYouLike] [nvarchar](100) NULL,
  [Suggestion] [nvarchar](max) NULL,
  [WhyApplying] [nvarchar](100) NULL,
  [WhyFitForPosition] [nvarchar](100) NULL,
  [Hobbies] [nvarchar](max) NULL,
  [Isdeleted] [bit] NULL,
  [IsCreatedOn] [datetime] NULL,
  [IsUpdatedOn] [datetime] NULL,
  [Jobtype] [nvarchar](100) NULL,
  [Worktype] [varchar](100) NULL,
  [AreaInterest] [nvarchar](100) NULL,
  [ApplicantCountry] [nvarchar](50) NULL,
  [ApplicantState] [nvarchar](50) NULL,
  [ApplicantCity] [nvarchar](50) NULL,
  [HearAboutUs] [nvarchar](50) NULL,
  [HearAboutUsTextbox] [nvarchar](100) NULL,
  CONSTRAINT [PK_Career] PRIMARY KEY CLUSTERED
  (
  [Id] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO



  """

  @primary_key {:id, :id, autogenerate: true}
  @derive {Phoenix.Param, key: :id}
  schema "Career" do

    # CREATE TABLE [dbo].[Career](
    #field :id, :integer
    field :name, :string, source: :"Name"
    field :email_address, :string, source: :"EmailAddress"
    field :phone_number, :string, source: :"PhoneNumber"
    field :school, :string, source: :"School"
    field :major, :string, source: :"Major"
    field :graduation_date, :date, source: :"GraduationDate"
    field :resume, :string, source: :"Resume"
    field :cover_letter, :string, source: :"CoverLetter"
    field :is_downloded, :boolean, source: :"Isdownloded"
    field :refferal_code, :string, source: :"RefferalCode"
    field :is_android_or_ios, :string, source: :"IsAndroidorIOS"
    field :is_intitutive_and_easy, :integer, source: :"IsIntitutiveandEasy"
    field :is_fast, :integer, source: :"Isfast"
    field :is_cool_and_apealling, :integer, source: :"Iscoolandapealing"
    field :dowant_travel, :integer, source: :"DowantTravel"
    field :features_you_like, :string, source: :"FeaturesYouLike"
    field :suggestion, :string, source: :"Suggestion"
    field :why_applying, :string, source: :"WhyApplying"
    field :why_fit_for_position, :string, source: :"WhyFitForPosition"
    field :hobbies, :string, source: :"Hobbies"
    field :isdeleted, :boolean, source: :"Isdeleted"
    field :is_created_on, :utc_datetime, source: :"IsCreatedOn"
    field :is_updated_on, :utc_datetime, source: :"IsUpdatedOn"
    field :job_type, :string, source: :"Jobtype"
    field :work_type, :string, source: :"Worktype"
    field :area_interest, :string, source: :"AreaInterest"
    field :applicant_country, :string, source: :"ApplicantCountry"
    field :applicant_state, :string, source: :"ApplicantState"
    field :applicant_city, :string, source: :"ApplicantCity"
    field :hear_about_us, :string, source: :"HearAboutUs"
    field :hear_about_us_textbox, :string, source: :"HearAboutUsTextbox"

  end
end
