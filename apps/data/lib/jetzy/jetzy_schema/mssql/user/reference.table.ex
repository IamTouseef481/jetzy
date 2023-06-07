defmodule JetzySchema.MSSQL.User.Reference.Table do
  use Ecto.Schema
  @nmid_index 1

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserReference")
  # ENTRY UserReference JetzySchema.MSSQL.User.Reference.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserReference]    Script Date: 2/24/2020 10:39:23 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserReference](
  [UserRefId] [bigint] IDENTITY(1,1) NOT NULL,
  [UserReferralCode] [varchar](100) NOT NULL,
  [UserInterestIDs] [int] NOT NULL,
  [CreatedDate] [datetime] NULL,
  [LastModifiedDate] [datetime] NULL,
  PRIMARY KEY CLUSTERED
  (
  [UserRefId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserReference] ADD  CONSTRAINT [DF_UserReference_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[UserReference] ADD  CONSTRAINT [DF_UserReference_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"UserRefId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserReference" do
    # CREATE TABLE [dbo].[UserReference](
    #field :user_ref_id, :integer, source: :"UserRefId"
    field :user_referral_code, :string, source: :"UserReferralCode"
    field :user_interest_id, :integer, source: :"UserInterestIDs"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifiedDate"
  end
end
