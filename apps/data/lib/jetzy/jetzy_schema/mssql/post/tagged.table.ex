defmodule JetzySchema.MSSQL.Post.Tagged.Table do
  use Ecto.Schema
  @nmid_index 30

  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"UserShoutoutsTagged")
  # ENTRY UserShoutoutsTagged JetzySchema.MSSQL.User.ShoutOut.Tagged.Table

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[UserShoutoutsTagged]    Script Date: 2/24/2020 10:47:59 AM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[UserShoutoutsTagged](
  [TaggedId] [int] IDENTITY(1,1) NOT NULL,
  [ShoutoutId] [bigint] NOT NULL,
  [Name] [uniqueidentifier] NULL,
  [Email] [varchar](100) NULL,
  [ContactNumber] [varchar](50) NULL,
  [Flag] [int] NOT NULL,
  [CreatedOn] [datetime] NOT NULL,
  [ModifiedOn] [datetime] NOT NULL,
  PRIMARY KEY CLUSTERED
  (
  [TaggedId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[UserShoutoutsTagged] ADD  CONSTRAINT [UserShoutoutsTagged_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
  GO

  ALTER TABLE [dbo].[UserShoutoutsTagged] ADD  CONSTRAINT [UserShoutoutsTagged_ModifiedOn]  DEFAULT (getdate()) FOR [ModifiedOn]
  GO

  ALTER TABLE [dbo].[UserShoutoutsTagged]  WITH CHECK ADD  CONSTRAINT [FK_ShoutoutsTagg_usershoutouts] FOREIGN KEY([ShoutoutId])
  REFERENCES [dbo].[UserShoutouts] ([ShoutoutId])
  GO

  ALTER TABLE [dbo].[UserShoutoutsTagged] CHECK CONSTRAINT [FK_ShoutoutsTagg_usershoutouts]
  GO



  """


  @primary_key {:id, :id, autogenerate: true, source: :"TaggedId"}
  @derive {Phoenix.Param, key: :id}
  schema "UserShoutoutsTagged" do
    # CREATE TABLE [dbo].[UserShoutoutsTagged](
    # field :tagged_id, :integer, source: :"TaggedId"
    field :post_id, :integer, source: :"ShoutoutId"
    field :name, Tds.Ecto.UUID, source: :"Name"
    field :email, :string, source: :"Email"
    field :contact_number, :string, source: :"ContactNumber"
    field :flag, :integer, source: :"Flag"
    field :created_on, :utc_datetime, source: :"CreatedOn"
    field :modified_on, :utc_datetime, source: :"ModifiedOn"
  end

  def contact(self, _context, _options \\ nil) do
    cond do
      (is_bitstring(self.email) && String.length(self.email) > 0) || (is_bitstring(self.contact_number) && String.length(self.contact_number) > 0) ->
        email = (is_bitstring(self.email) && String.length(self.email) > 0) && self.email
        email = email && String.split(email, "|") |> Enum.at(1)
        mobile = (is_bitstring(self.contact_number) && String.length(self.contact_number) > 0) && self.contact_number
        name = String.split("#{email || mobile}", "|") |> Enum.at(0)
         %Jetzy.Post.Tag.Contact.Entity{
           name: name,
           email: email,
           mobile: mobile,
           status: :pending,
           time_stamp: Noizu.DomainObject.TimeStamp.Second.import(self.created_on, self.modified_on, nil)
         }
      :else -> nil
    end
  end

  def contact!(self, _context, _options \\ nil) do
    cond do
      (is_bitstring(self.email) && String.length(self.email) > 0) || (is_bitstring(self.contact_number) && String.length(self.contact_number) > 0) ->
        email = (is_bitstring(self.email) && String.length(self.email) > 0) && self.email
        email = email && String.split(email, "|") |> Enum.at(1)
        mobile = (is_bitstring(self.contact_number) && String.length(self.contact_number) > 0) && self.contact_number
        name = String.split("#{email || mobile}", "|") |> Enum.at(0)
        %Jetzy.Post.Tag.Contact.Entity{
          name: name,
          email: email,
          mobile: mobile,
          status: :pending,
          time_stamp: Noizu.DomainObject.TimeStamp.Second.import(self.created_on, self.modified_on, nil)
        }
      :else -> nil
    end
  end

  def tagged(self, context, options \\ nil) do
    case self.name do
      "00000000-0000-0000-0000-000000000000" -> nil
      v when is_bitstring(v) -> Jetzy.User.Repo.by_guid(self.name, context, options)
      _  -> nil
    end
  end


  def tagged!(self, context, options \\ nil) do
    case self.name do
      "00000000-0000-0000-0000-000000000000" -> nil
      v when is_bitstring(v) -> Jetzy.User.Repo.by_guid!(self.name, context, options)
      _  -> nil
    end
  end

  def status(self, _context, _options \\ nil) do
    case self.flag do
      nil -> :active
      0 -> :active
      1 -> :pending
      _ -> :disabled
    end
  end


end
