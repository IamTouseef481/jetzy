defmodule JetzySchema.MSSQL.Post.Interest.Table do
  use Ecto.Schema
  @nmid_index 28

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserShoutoutInterest")
  # ENTRY UserShoutoutInterest JetzySchema.MSSQL.User.ShoutOut.Interest.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserShoutoutInterest]    Script Date: 2/24/2020 10:45:42 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserShoutoutInterest](
  [ShoutoutInterestId] [bigint] IDENTITY(1,1) NOT NULL,
  [ShoutoutId] [bigint] NOT NULL,
  [UserId] [uniqueidentifier] NOT NULL,
  [InterestId] [int] NOT NULL,
  [CreatedOn] [datetime] NULL,
  [UpdatedOn] [datetime] NULL,
  PRIMARY KEY CLUSTERED
  (
  [ShoutoutInterestId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO



  """

  @primary_key {:id, :id, autogenerate: true, source: :"ShoutoutInterestId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserShoutoutInterest" do
    # CREATE TABLE [dbo].[UserShoutoutInterest](
    # field :shoutout_interest_id, :integer, source: :"ShoutoutInterestId"
    field :post_id, :integer, source: :"ShoutoutId"
    field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :interest_id, :integer, source: :"InterestId"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"UpdatedOn"
  end


  def by_legacy(guid, _context, _options \\ []) do
    JetzySchema.MSSQL.Repo.get(JetzySchema.MSSQL.Post.Interest.Table, guid)
  end
  def by_legacy!(guid, _context, _options \\ []) do
    JetzySchema.MSSQL.Repo.get(JetzySchema.MSSQL.Post.Interest.Table, guid)
  end

  def interest(record, context, options) do
    Jetzy.Interest.Repo.by_legacy(record.interest_id, context, options)
  end

  def interest!(record, context, options) do
    Jetzy.Interest.Repo.by_legacy!(record.interest_id, context, options)
  end



  def added_by(record, context, options) do
    Jetzy.User.Repo.by_guid(record.user_id, context, options)
  end

  def added_by!(record, context, options) do
    Jetzy.User.Repo.by_guid!(record.user_id, context, options)
  end


end
