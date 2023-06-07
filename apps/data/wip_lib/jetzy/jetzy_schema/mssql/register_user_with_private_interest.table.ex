defmodule JetzySchema.MSSQL.RegisterUserWithPrivateInterest.Table do
  use Ecto.Schema
  @nmid_index 33

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"RegisterUserWithPrivateInterest")
  # ENTRY RegisterUserWithPrivateInterest JetzySchema.MSSQL.RegisterUserWithPrivateInterest.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[RegisterUserWithPrivateInterest]    Script Date: 2/24/2020 10:09:39 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[RegisterUserWithPrivateInterest](
  [Id] [int] IDENTITY(1,1) NOT NULL,
  [Emails] [nvarchar](200) NOT NULL,
  [PrivateInterestId] [int] NOT NULL,
  [IsDeleted] [bit] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [UpdatedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [Id] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[RegisterUserWithPrivateInterest] ADD  CONSTRAINT [RegisterUserWithPrivateInterest_isdeleted]  DEFAULT ((0)) FOR [IsDeleted]
  GO

  ALTER TABLE [dbo].[RegisterUserWithPrivateInterest] ADD  CONSTRAINT [RegisterUserWithPrivateInterest_created_on]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[RegisterUserWithPrivateInterest] ADD  CONSTRAINT [RegisterUserWithPrivateInterest_updated_on]  DEFAULT (getdate()) FOR [UpdatedOn]
  GO

  ALTER TABLE [dbo].[RegisterUserWithPrivateInterest]  WITH CHECK ADD  CONSTRAINT [RegisterUserWithPrivateInterest_PrivateInterestId] FOREIGN KEY([PrivateInterestId])
  REFERENCES [dbo].[Interest] ([Id])
  GO

  ALTER TABLE [dbo].[RegisterUserWithPrivateInterest] CHECK CONSTRAINT [RegisterUserWithPrivateInterest_PrivateInterestId]
  GO



  """

  @primary_key {:id, :id, autogenerate: false}
  @derive {Phoenix.Param, key: :id}
  schema "RegisterUserWithPrivateInterest" do
    # CREATE TABLE [dbo].[RegisterUserWithPrivateInterest](
    # field :id, :integer
    field :emails, :string, source: :"Emails"
    field :private_interest_id, :integer, source: :"PrivateInterestId"
    field :deleted, :boolean, source: :"IsDeleted"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end
end
