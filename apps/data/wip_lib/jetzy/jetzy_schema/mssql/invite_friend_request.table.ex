defmodule JetzySchema.MSSQL.InviteFriendRequest.Table do
  use Ecto.Schema
  @nmid_index 18

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"InviteFriendRequest")
  # ENTRY InviteFriendRequest JetzySchema.MSSQL.InviteFriendRequest.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[InviteFriendRequest]    Script Date: 2/24/2020 9:55:28 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[InviteFriendRequest](
  [RequestId] [uniqueidentifier] NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [Friendemail] [nvarchar](100) NULL,
  [SocialId] [nvarchar](100) NULL,
  [RequestCode] [nvarchar](50) NOT NULL,
  [CreatedDate] [datetime] NOT NULL,
  [LastModifiedDate] [datetime] NOT NULL,
  [FirstName] [nvarchar](100) NULL,
  [LastName] [nvarchar](100) NULL,
  CONSTRAINT [PK_InviteFriendRequest] PRIMARY KEY CLUSTERED
  (
  [RequestId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[InviteFriendRequest] ADD  CONSTRAINT [DF_InviteFriendRequest_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[InviteFriendRequest] ADD  CONSTRAINT [DF_InviteFriendRequest_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
  GO



  """

  @primary_key {:id, Tds.Ecto.UUID, autogenerate: true, source: :"RequestId"}
  @derive {Phoenix.Param, key: :id}
  schema "InviteFriendRequest" do
    # CREATE TABLE [dbo].[InviteFriendRequest](
    #field :request_id, Tds.Ecto.UUID, source: :"RequestId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :friend_email, :string, source: :"Friendemail"
    field :social_id, :string, source: :"SocialId"
    field :request_code, :string, source: :"RequestCode"
    field :created_date, :utc_datetime, source: :"CreatedDate"
    field :last_modified_date, :utc_datetime, source: :"LastModifiedDate"
    field :first_name, :string, source: :"FirstName"
    field :last_name, :string, source: :"LastName"
  end
end
