defmodule JetzySchema.MSSQL.User.Interest.Tagged.Table do
  use Ecto.Schema
  @nmid_index 55

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserInterestTagged")
  # ENTRY UserInterestTagged JetzySchema.MSSQL.User.Interest.Tagged.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserInterestTagged]    Script Date: 2/24/2020 10:29:35 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserInterestTagged](
  [TaggedId] [int] IDENTITY(1,1) NOT NULL,
  [Email] [varchar](100) NULL,
  [ContactNumber] [varchar](50) NULL,
  [InterestId] [int] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [ModifiedOn] [datetime] NOT NULL,
  [IsAdmin] [bit] NOT NULL,
  [IsActive] [int] NOT NULL,
  [Flag] [int] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [TaggedId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserInterestTagged] ADD  CONSTRAINT [UserInterestTagged_created_on]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserInterestTagged] ADD  CONSTRAINT [UserInterestTagged_modified_on]  DEFAULT (getdate()) FOR [ModifiedOn]
  GO

  ALTER TABLE [dbo].[UserInterestTagged]  WITH CHECK ADD  CONSTRAINT [FK_Tagged_UserInterest] FOREIGN KEY([InterestId])
  REFERENCES [dbo].[Interest] ([Id])
  GO

  ALTER TABLE [dbo].[UserInterestTagged] CHECK CONSTRAINT [FK_Tagged_UserInterest]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"TaggedId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserInterestTagged" do
    # CREATE TABLE [dbo].[UserInterestTagged](
    # field :tagged_id, :integer, source: :"TaggedId"
    field :email, :string, source: :"Email"
    field :contact_number, :string, source: :"ContactNumber"
    field :interest_id, :integer, source: :"InterestId"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"ModifiedOn"
    field :is_admin, :boolean, source: :"IsAdmin"
    field :is_active, :integer, source: :"IsActive"
    field :flag, :integer, source: :"Flag"
  end
end
