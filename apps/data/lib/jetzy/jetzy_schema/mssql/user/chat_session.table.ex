defmodule JetzySchema.MSSQL.User.ChatSession.Table do
  use Ecto.Schema
  @nmid_index 43

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserChatSession")
  # ENTRY UserChatSession JetzySchema.MSSQL.User.ChatSession.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserChatSession]    Script Date: 2/24/2020 10:20:34 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserChatSession](
  [ChatSessionId] [uniqueidentifier] NOT NULL,
  [FirstUserId] [uniqueidentifier] NOT NULL,
  [SecondUserId] [uniqueidentifier] NOT NULL,
  [LastChatDate] [datetime] NOT NULL,
  CONSTRAINT [PK_UserChatSession] PRIMARY KEY CLUSTERED
  (
  [ChatSessionId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserChatSession] ADD  DEFAULT (getdate()) FOR [LastChatDate]
  GO



  """

  @primary_key {:id, Tds.Ecto.UUID, autogenerate: true, source: :"ChatSessionId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserChatSession" do
    # CREATE TABLE [dbo].[UserChatSession](
    # field :chat_session_id, Tds.Ecto.UUID, source: :"ChatSessionId"
    field :first_user_id, Tds.Ecto.UUID, source: :"FirstUserId"
    field :second_user_id, Tds.Ecto.UUID, source: :"SecondUserId"
    field :last_chat_date, :utc_datetime, source: :"LastChatDate"
  end
end
