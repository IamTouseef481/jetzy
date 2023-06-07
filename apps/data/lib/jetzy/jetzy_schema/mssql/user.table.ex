defmodule JetzySchema.MSSQL.User.Table do
  use Ecto.Schema
  @nmid_index 42
  import Ecto.Query, only: [from: 2]
  require JetzySchema.NoizuTableBehaviour
  JetzySchema.NoizuTableBehaviour.mssql_table(:"Users")
  #import Ecto.Query

  @moduledoc """
  USE [travellersconnect]
  GO

  /****** Object:  Table [dbo].[Users]    Script Date: 2/23/2020 4:18:53 PM ******/
  SET ANSI_NULLS ON
  GO

  SET QUOTED_IDENTIFIER ON
  GO

  CREATE TABLE [dbo].[Users](
  [UserId] [uniqueidentifier] NOT NULL,
  [FirstName] [nvarchar](100) NULL,
  [LastName] [nvarchar](100) NULL,
  [Email] [nvarchar](100) NULL,
  [Gender] [char](1) NULL,
  [DOB] [datetime] NULL,
  [Password] [nvarchar](200) NULL,
  [IsDeactivated] [bit] NOT NULL,
  [IsShowOnProfile] [bit] NOT NULL,
  [IsPushNotification] [bit] NOT NULL,
  [IsEnableChat] [bit] NOT NULL,
  [IsGroupchatEnable] [bit] NULL,
  [IsMomentsEnable] [bit] NULL,
  [CreatedDate] [datetime] NOT NULL,
  [LastModifiedDate] [datetime] NOT NULL,
  [HomeTownCity] [nvarchar](100) NULL,
  [HomeTownCountry] [nvarchar](100) NULL,
  [UserAbout] [nvarchar](1000) NULL,
  [LoginType] [char](1) NULL,
  [PanicMessage] [nvarchar](max) NULL,
  [QuickBloxId] [nvarchar](100) NULL,
  [SocialId] [nvarchar](100) NULL,
  [IsEmailVerified] [bit] NULL,
  [IsInfo] [bit] NULL,
  [CurrentCity] [nvarchar](100) NULL,
  [CurrentCountry] [nvarchar](100) NULL,
  [ImageName] [nvarchar](200) NULL,
  [QuickBloxPassword] [nvarchar](250) NULL,
  [ReferralCode] [nvarchar](100) NULL,
  [IsReferral] [bit] NULL,
  [FriendCode] [nvarchar](100) NULL,
  [IsDeleted] [bit] NULL,
  [UserIniviteType] [int] NULL,
  [UnSubScribe] [bit] NULL,
  [UserRole] [int] NULL,
  [IsProfileImageSync] [bit] NULL,
  [DobFull] [nvarchar](100) NULL,
  [School] [nvarchar](200) NULL,
  [Employer] [nvarchar](200) NULL,
  [Latitude] [float] NULL,
  [Longitude] [float] NULL,
  CONSTRAINT [PK_Users_1] PRIMARY KEY CLUSTERED
  (
  [UserId] ASC
  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
  ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
  GO

  ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_IsDeactivated]  DEFAULT ((0)) FOR [IsDeactivated]
  GO

  ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_IsShowOnProfile]  DEFAULT ((1)) FOR [IsShowOnProfile]
  GO

  ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_IsPushNotification]  DEFAULT ((1)) FOR [IsPushNotification]
  GO

  ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_IsEnableChat]  DEFAULT ((1)) FOR [IsEnableChat]
  GO

  ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_IsGroupchatEnable]  DEFAULT ((1)) FOR [IsGroupchatEnable]
  GO

  ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_IsMomentsEnable]  DEFAULT ((1)) FOR [IsMomentsEnable]
  GO

  ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_User_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
  GO

  ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_User_LastModifiedDate]  DEFAULT (getdate()) FOR [LastModifiedDate]
  GO

  ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_IsEmailVerified]  DEFAULT ((0)) FOR [IsEmailVerified]
  GO

  ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_IsInfo]  DEFAULT ((0)) FOR [IsInfo]
  GO

  ALTER TABLE [dbo].[Users] ADD  DEFAULT ((0)) FOR [IsReferral]
  GO

  ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [df_Users_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
  GO

  ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [df_Users_UserIniviteType]  DEFAULT ((0)) FOR [UserIniviteType]
  GO

  ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [df_Users_UnSubScribe]  DEFAULT ((0)) FOR [UnSubScribe]
  GO

  ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [df_Users_IsProfileImageSync]  DEFAULT ((0)) FOR [IsProfileImageSync]
  GO

  ALTER TABLE [dbo].[Users] ADD  DEFAULT (NULL) FOR [School]
  GO

  ALTER TABLE [dbo].[Users] ADD  DEFAULT (NULL) FOR [Employer]
  GO
  """


  @login_type %{
    "1" => "email",
    "2" => "facebook",
    "3" => "email", # twitter
    "4" => "email", # linkedin
    "5" => "apple",
    "email" => "email",
    "facebook" => "facebook",
    "apple" => "apple"
  }

  @primary_key {:id, Tds.Ecto.UUID, autogenerate: false, source: :"UserId"}
  @derive {Phoenix.Param, key: :id}
  schema "Users" do
    # CREATE TABLE [dbo].[Users](
    #field :user_id, Tds.Ecto.UUID, source: :"UserId"
    field :first_name, :string, source: :"FirstName"
    field :last_name, :string, source: :"LastName"
    field :email, :string, source: :"Email"
    field :gender, JetzySchema.Types.MSSQL.GenderType, source: :"Gender"
    field :dob, :utc_datetime, source: :"DOB"
    field :password, :string, source: :"Password"
    field :is_deactivated, :boolean, source: :"IsDeactivated"
    field :is_show_on_profile, :boolean, source: :"IsShowOnProfile"
    field :is_push_notification, :boolean, source: :"IsPushNotification"
    field :is_enable_chat, :boolean, source: :"IsEnableChat"
    field :is_group_chat_enable, :boolean, source: :"IsGroupchatEnable"
    field :is_moments_enable, :boolean, source: :"IsMomentsEnable"
    field :created_on, :utc_datetime, source: :"CreatedDate"
    field :modified_on, :utc_datetime, source: :"LastModifiedDate"
    field :home_town_city, :string, source: :"HomeTownCity"
    field :home_town_country, :string, source: :"HomeTownCountry"
    field :user_about, :string, load_in_query: true, source: :"UserAbout"
    field :login_type, :string, source: :"LoginType"
    field :panic_message, :string, load_in_query: true, source: :"PanicMessage"
    field :quick_blox_id, :string, source: :"QuickBloxId"
    field :social_id, :string, source: :"SocialId"
    field :is_email_verified, :boolean, source: :"IsEmailVerified"
    field :is_info, :boolean, source: :"IsInfo"
    field :current_city, :string, source: :"CurrentCity"
    field :current_country, :string, source: :"CurrentCountry"
    field :image_name, :string, source: :"ImageName"
    field :quick_blox_password, :string, source: :"QuickBloxPassword"
    field :referral_code, :string, source: :"ReferralCode"
    field :is_referral, :boolean, source: :"IsReferral"
    field :friend_code, :string, source: :"FriendCode"
    field :deleted, :boolean, source: :"IsDeleted"
    field :user_inivite_type, :integer, source: :"UserIniviteType"
    field :unsubscribe, :boolean, source: :"UnSubScribe"
    field :user_role, :integer, source: :"UserRole"
    field :is_profile_image_sync, :boolean, source: :"IsProfileImageSync"
    field :dob_full, :string, source: :"DobFull"
    field :school, :string, source: :"School"
    field :employer, :string, source: :"Employer"
    field :latitude, :decimal, source: :"Latitude"
    field :longitude, :decimal, source: :"Longitude"

    field :approval_status, :string, source: :"ApprovalStatus"
    field :is_select_enabled, :boolean, source: :"IsSelectEnabled"
    field :ContributionMsg, :string, source: :"ContributionMsg"
    field :authentication_key, :string, source: :"AuthenticationKey"
    field :profile_photo, :string, source: :"ProfilePhoto"
    field :verification_photo, :string, source: :"VerificationPhoto"
    field :is_jetzy_exclusive, :boolean, source: :"IsJetzyExclusive"
  end
  def relations(record, context, options \\ nil)

  def relations(%{__struct__: JetzySchema.MSSQL.User.Table} = record, context, options), do: relations(record.id, context, options)
  def relations(guid, _context, _options) when is_bitstring(guid) do
    query = from u in JetzySchema.MSSQL.User.Friend.Table,
                 where: u.user_id == ^guid,
                 select: u
    JetzySchema.MSSQL.Repo.all(query)
  end

  def residence(%{__struct__: JetzySchema.MSSQL.User.Table} = record, context, options \\ nil) do
    Jetzy.Location.City.Repo.by_city_country(record.home_town_city, record.home_town_country, context, options)
  end

  def location(%{__struct__: JetzySchema.MSSQL.User.Table} = record, context, options \\ nil) do
    Jetzy.Location.City.Repo.by_city_country(record.current_city, record.current_country, context, options)
  end

  def channels(%{__struct__: JetzySchema.MSSQL.User.Table} = record, context, options \\ nil) do
    email = %{
      channel_type: :email,
      time_stamp: time_stamp(record, context, options),
      fields: %{
        email: record.email,
        verified: record.is_email_verified
      }
    }
    chat = record.quick_blox_id && %{
      channel_type: :quick_blox,
      time_stamp: time_stamp(record, context, options),
      fields: %{
        quick_blox_user: record.quick_blox_id,
        quick_blox_auth: record.quick_blox_password
      }
    }
    entities = Enum.filter([email, chat], &(&1))
    %Jetzy.Entity.Contact.Channel.Repo{
      entities: entities,
      length: length(entities),
      __transient__: %{
        partials: true
      }
    }
  end


  def time_stamp(%{__struct__: JetzySchema.MSSQL.User.Table} = record, _context, _options) do
    %Noizu.DomainObject.TimeStamp.Second{
      created_on: record.created_on && DateTime.truncate(record.created_on, :second),
      modified_on: (record.modified_on || record.created_on) && DateTime.truncate((record.modified_on || record.created_on), :second),
      deleted_on: (record.deleted && (record.modified_on || record.created_on)) && DateTime.truncate((record.modified_on || record.created_on), :second) || nil
    }
  end

  def legacy_session(ref, context, options \\ nil)
  def legacy_session({guid, session}, _context, options) do
    now = options[:current_time] || DateTime.utc_now()
    #-----------------
    # session
    query = from s in JetzySchema.MSSQL.User.Session.Table,
                 where: s.user_id == ^guid,
                 where: s.session_id == ^session,
                 select: s,
                 limit: 1
    _session_credential = case JetzySchema.MSSQL.Repo.all(query) do
                            [s | _] ->
                              %Jetzy.User.Credential.Entity{
                                origin: :legacy,
                                status: s.is_active && :active || :inactive,
                                credential_type: :api_legacy_session,
                                credential_provider: :api,
                                settings: %Jetzy.User.Credential.JetzyLegacySession{
                                  guid: guid,
                                  session: s.session_id,
                                  # TODO device
                                  session_active: s.is_active,
                                  recheck_after: Timex.shift(now, hours: 1),
                                },
                                time_stamp: %Noizu.DomainObject.TimeStamp.Second{
                                  created_on: now,
                                  modified_on: now
                                },
                                __transient__: %{
                                  incomplete: true
                                }
                              }
                            _ -> nil
                          end
  end
  def legacy_session(%{__struct__: JetzySchema.MSSQL.User.Table} = record, _context, options) do
    now = options[:current_time] || DateTime.utc_now()
    guid = String.upcase(record.id)
    #-----------------
    # session
    query = from s in JetzySchema.MSSQL.User.Session.Table,
                 where: s.user_id == ^record.id,
                 where: s.is_active == true,
                 select: s,
                 limit: 1
    _session_credential = case JetzySchema.MSSQL.Repo.all(query) do
                            [s | _] ->
                              %Jetzy.User.Credential.Entity{
                                origin: :legacy,
                                status: :active,
                                credential_type: :api_legacy_session,
                                credential_provider: :api,
                                settings: %Jetzy.User.Credential.JetzyLegacySession{
                                  guid: guid,
                                  session: s.session_id,
                                  # TODO device
                                  session_active: true,
                                  recheck_after: Timex.shift(now, hours: 1),
                                },
                                time_stamp: %Noizu.DomainObject.TimeStamp.Second{
                                  created_on: now,
                                  modified_on: now
                                },
                                __transient__: %{
                                  incomplete: true
                                }
                              }
                            _ -> nil
                          end
  end

  def legacy_credentials(%{__struct__: JetzySchema.MSSQL.User.Table} = record, _context, options \\ nil) do
    now = options[:current_time] || DateTime.utc_now()
    guid = String.upcase(record.id)
    record.email && record.password && %Jetzy.User.Credential.Entity{
      origin: :legacy,
      status: :active,
      credential_type: :api_legacy,
      credential_provider: :api,
      settings: %Jetzy.User.Credential.JetzyLegacy{
        login_name: String.trim(record.email)
                    |> String.downcase,
        password_hash: record.password,
        guid: guid,
      },
      time_stamp: %Noizu.DomainObject.TimeStamp.Second{
        created_on: record.created_on && DateTime.truncate(record.created_on, :second),
        modified_on: now
      },
      __transient__: %{
        incomplete: true,
      }
    }
  end

  def social_credentials(record, context, options) do
    now = options[:current_time] || DateTime.utc_now()
    type = @login_types[record.login_type]
    cond do
      type in [:apple, :facebook, :google, :linkedin, :twitter] ->
        %Jetzy.User.Credential.Entity{
          origin: :legacy,
          status: :active,
          credential_type: :social,
          credential_provider: :api,
          settings: %Jetzy.User.Credential.Social{
            social_identifier: record.social_id,
            social_type: type,
          },
          time_stamp: %Noizu.DomainObject.TimeStamp.Second{created_on: record.created_on && DateTime.truncate(record.created_on, :second), modified_on: now},
        }
      :else -> nil
    end
  end

  def credentials(%{__struct__: JetzySchema.MSSQL.User.Table} = record, context, options \\ nil) do
    #now = options[:current_time] || DateTime.utc_now()
    #guid = String.upcase(record.id)
    session_credential = legacy_session(record, context, options)
    legacy_user_password = legacy_credentials(record, context, options)
    social_credentials = social_credentials(record, context, options)
    entities = Enum.filter([legacy_user_password, session_credential, social_credentials], &(&1))
    raw_password = case (record.password && Jetzy.User.Credential.JetzyLegacy.decrypt_hash_password(record.password)) do
                     {:ok, v} -> v
                     _ -> "ERR|" <> (:rand.uniform(999999999999) |> Integer.to_string(16) |> String.pad_leading(5, "Z")) <> (:rand.uniform(999999999999) |> Integer.to_string(16) |> String.pad_leading(5, "v"))
                   end
    %Jetzy.User.Credential.Repo{
      entities: entities,
      length: length(entities),
      __transient__: %{
        partials: true,
        password: raw_password,
      }
    }
  end

  #-------------------------
  # profile_image/3
  #-------------------------
  def profile_image(%{__struct__: JetzySchema.MSSQL.User.Table} = record, _context, _options \\ nil) do
    cond do
      record.image_name && String.length(record.image_name) > 0 ->
        "https://api.jetzyapp.com/Images/ProfileImage/#{record.image_name}.jpg"
      record.profile_photo && String.length(record.profile_photo) > 0 ->
        "https://api.jetzyapp.com/Images/ProfileImage/#{record.profile_photo}.jpg"
      :else ->
        query = from p in JetzySchema.MSSQL.User.ProfileImage.Table,
                     where: p.user_id == ^record.id,
                     where: p.is_current == true,
                     select: p,
                     limit: 1
        case JetzySchema.MSSQL.Repo.all(query) do
          [%{__struct__: JetzySchema.MSSQL.User.ProfileImage.Table} = p | _] -> p.image_name && "https://api.jetzyapp.com/Images/ProfileImage/#{p.image_name}.jpg"
          _ -> nil
        end
    end
  end

  #-------------------------
  # interests/3
  #-------------------------
  def interests(%{__struct__: JetzySchema.MSSQL.User.Table} = record, _context, _options \\ nil) do
    records = (from i in JetzySchema.MSSQL.User.Interest.Table,
                    where: i.user_id == ^record.id,
                    select: i)
              |> JetzySchema.MSSQL.Repo.all()
    %Jetzy.User.Interest.Repo{
      entities: records,
      length: length(records),
      __transient__: %{
        partials: true
      }
    }
  end



  def by_guid(guid, context, options \\ nil) do
    by_guid!(guid, context, options)
  end
  def by_guid!(guid, _context, _options \\ nil) do
    guid = String.upcase(guid)
    query = from u in JetzySchema.MSSQL.User.Table,
                 where: u.id == ^guid,
                 limit: 1
    case JetzySchema.MSSQL.Repo.all(query) do
      [r | _] -> r
      _ -> nil
    end
  end

  def by_login(login, password, context, options \\ nil) do
    by_login!(login, password, context, options)
  end
  def by_login!(login, password, _context, _options \\ nil) do
    query = from u in JetzySchema.MSSQL.User.Table,
                 where: u.email == ^login,
                 where: u.password == ^password,
                 limit: 1
    case JetzySchema.MSSQL.Repo.all(query) do
      [r | _] -> r
      _ -> nil
    end
  end

  def by_login_name(login, context, options \\ nil) do
    by_login_name!(login, context, options)
  end
  def by_login_name!(login, _context, _options \\ nil) do
    query = from u in JetzySchema.MSSQL.User.Table,
                 where: u.email == ^login,
                 limit: 1
    case JetzySchema.MSSQL.Repo.all(query) do
      [r | _] -> r
      _ -> nil
    end
  end

  def user_images(guid, context, options) do
    query = from u in JetzySchema.MSSQL.User.Image.Table,
                 where: u.user_id == ^guid
    JetzySchema.MSSQL.Repo.all(query)
  end


end
