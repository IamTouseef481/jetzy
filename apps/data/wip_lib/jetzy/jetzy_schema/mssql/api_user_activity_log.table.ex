defmodule JetzySchema.MSSQL.ApiUserActivityLog.Table do
  use Ecto.Schema
  @nmid_index 6

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"APIUserActivityLog")
  # ENTRY APIUserActivityLog JetzySchema.MSSQL.ApiUserActivityLog.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[APIUserActivityLog]    Script Date: 2/24/2020 9:41:58 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[APIUserActivityLog](
  [ActivityLogId] [int] IDENTITY(1,1) NOT NULL,
  [Old_UserId] [nvarchar](128) NOT NULL,
  [EndPoint] [nvarchar](128) NULL,
  [When] [datetime] NULL,
  [API_Token] [nvarchar](250) NULL,
  [ApiVersion] [int] NULL,
  [RequestContent] [nvarchar](max) NULL,
  [ErrorClass] [nvarchar](100) NULL,
  [ErrorCode] [nvarchar](100) NULL,
  [ErrorDescription] [nvarchar](100) NULL,
  [DeviceId] [nvarchar](100) NULL,
  [DeviceType] [int] NULL,
  [AppVersion] [nvarchar](50) NULL,
  [UserId] [uniqueidentifier] NULL,
  CONSTRAINT [PK_UserActivityLogId] PRIMARY KEY CLUSTERED
  (
  [ActivityLogId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[APIUserActivityLog] ADD  CONSTRAINT [DF_APIUserActivityLogAPI_Token]  DEFAULT (N'TC') FOR [API_Token]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"ActivityLogId"}
  @derive {Phoenix.Param, key: :id}
  schema "APIUserActivityLog" do
    # CREATE TABLE [dbo].[APIUserActivityLog](
    #field :activity_log_id, :integer, source: :"ActivityLogId"
    field :old_user_id, :string, source: :"Old_UserId"
    field :end_point, :string, source: :"EndPoint"
    field :when, :utc_datetime, source: :"When"
    field :api_token, :string, source: :"API_Token"
    field :api_version, :integer, source: :"ApiVersion"
    field :request_content, :string, source: :"RequestContent"
    field :error_class, :string, source: :"ErrorClass"
    field :error_code, :string, source: :"ErrorCode"
    field :error_description, :string, source: :"ErrorDescription"
    field :device_id, :string, source: :"DeviceId"
    field :device_type, :integer, source: :"DeviceType"
    field :app_version, :string, source: :"AppVersion"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
  end
end
