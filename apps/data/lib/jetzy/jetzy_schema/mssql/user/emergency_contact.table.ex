defmodule JetzySchema.MSSQL.User.EmergencyContact.Table do
  use Ecto.Schema
  @nmid_index 46

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserEmergencyContact")
  # ENTRY UserEmergencyContact JetzySchema.MSSQL.User.EmergencyContact.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserEmergencyContact]    Script Date: 2/24/2020 10:22:34 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserEmergencyContact](
  [UserEmergencyContactId] [bigint] IDENTITY(1,1) NOT NULL,
  [UserFirstName] [nvarchar](100) NOT NULL,
  [UserLastName] [nvarchar](100) NULL,
  [UserEmail] [nvarchar](100) NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [IsActive] [bit] NOT NULL,
  CONSTRAINT [PK_UserEmergencyContact] PRIMARY KEY CLUSTERED
  (
  [UserEmergencyContactId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserEmergencyContact] ADD  CONSTRAINT [DF_UserEmergencyContact_IsActive]  DEFAULT ((0)) FOR [IsActive]
  GO

  ALTER TABLE [dbo].[UserEmergencyContact]  WITH CHECK ADD  CONSTRAINT [FK_UserEmergencyContact_Users] FOREIGN KEY([UserId])
  REFERENCES [dbo].[Users] ([UserId])
  GO

  ALTER TABLE [dbo].[UserEmergencyContact] CHECK CONSTRAINT [FK_UserEmergencyContact_Users]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"UserEmergencyContactId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserEmergencyContact" do
    # CREATE TABLE [dbo].[UserEmergencyContact](
    # field :user_emergency_contact_id, :integer, source: :"UserEmergencyContactId"
    field :user_first_name, :string, source: :"UserFirstName"
    field :user_last_name, :string, source: :"UserLastName"
    field :user_email, :string, source: :"UserEmail"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :is_active, :boolean, source: :"IsActive"
  end
end
