defmodule JetzySchema.MSSQL.User.LastActivityLog.Table do
  use Ecto.Schema
  @nmid_index 56

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserLastActivityLog")
  # ENTRY UserLastActivityLog JetzySchema.MSSQL.User.LastActivityLog.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserLastActivityLog]    Script Date: 2/24/2020 10:30:09 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserLastActivityLog](
  [UserLastActivityLogId] [bigint] IDENTITY(1,1) NOT NULL,
  [UserId] [uniqueidentifier] NULL,
  [EndPoint] [nvarchar](128) NULL,
  [AppVersion] [nvarchar](50) NULL,
  [ApiVersion] [int] NULL,
  [DeviceId] [nvarchar](100) NULL,
  [DeviceType] [int] NULL,
  [CreatedOn] [datetime] NULL,
  [UpdatedOn] [datetime] NULL,
  PRIMARY KEY CLUSTERED
  (
  [UserLastActivityLogId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"UserLastActivityLogId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserLastActivityLog" do
    # CREATE TABLE [dbo].[UserLastActivityLog](
    # field :user_last_activity_log_id, :integer, source: :"UserLastActivityLogId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :end_point, :string, source: :"EndPoint"
    field :app_version, :string, source: :"AppVersion"
    field :api_version, :integer, source: :"ApiVersion"
    field :device_id, :string, source: :"DeviceId"
    field :device_type, :integer, source: :"DeviceType"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end
end
