defmodule Data.Schema.User do
  @moduledoc """
    The schema for User
  """
  use Data.Schema
  @derive Noizu.ERP
  @derive Tanbits.Shim
  @derive Noizu.EctoEntity.Protocol
  @type t :: %__MODULE__{
               id: binary,
               deleted_at: DateTime.t | nil,
               is_deleted: boolean,
               email: String.t | nil,
               social_id: String.t | nil,
               quick_blox_id: String.t | nil,
               image_name: String.t | nil,
               current_city: String.t | nil,
               last_name: String.t | nil,
               gender: String.t | nil,
               login_type: String.t | nil,
               first_name: String.t | nil,
               home_town_city: String.t | nil,
               longitude: float,
               school: String.t | nil,
               password: String.t | nil,
               current_country: String.t | nil,
               dob: :date,
               age: integer,
               language: String.t | nil,
               is_selfie_verified: boolean | false,
               user_verification_image: String.t | nil,
               is_referral: boolean,
               dob_full: String.t | nil,
               is_email_verified: boolean,
               referral_code: String.t | nil,
               is_deactivated: boolean,
               latitude: float,
               panic_message: String.t | nil,
               user_about: String.t | nil,
               home_town_country: String.t | nil,
               quick_blox_password: String.t | nil,
               is_active: boolean | false,
               friend_code: String.t | nil,
               verification_token: String.t | nil,
               employer:  String.t | nil,
               blur_hash: String.t | nil,
               image_identifier: integer | nil,
               small_image_name: String.t | nil,
               shareable_link: String.t,
               direct_login_link: String.t,
               is_self_deactivated: boolean,
               chat_settings: Map.t,
               user_level: atom,
               influencer_level: atom,
             }

  @generated_fields ~w|
  effective_status
  |a

  @joined_fields ~w|

  |a

  @required_fields ~w|
  |a

  @optional_fields ~w|
    deleted_at
    first_name
    last_name
    email
    gender
    dob
    password
    is_deactivated
    home_town_city
    home_town_country
    user_about
    login_type
    panic_message
    quick_blox_id
    social_id
    is_email_verified
    current_city
    current_country
    image_name
    quick_blox_password
    referral_code
    is_referral
    is_active
    friend_code
    is_deleted
    dob_full
    school
    latitude
    longitude
    age
    language
    is_selfie_verified
    user_verification_image
    verification_token
    employer
    blur_hash
    small_image_name
    shareable_link
    direct_login_link
    image_identifier
    is_self_deactivated
    user_level
    influencer_level
    jetzy_exclusive_status
    jetzy_select_status
  |a

  @all_fields @required_fields ++ @optional_fields

  @etiquette_message """
  It’s great that you want to connect with fellow Jetzy members, we request you to be honest, kind and respectful to other members on Jetzy.\n\n Remember these rules as you message:\n\n1. Avoid starting the conversation with hi/hello. Explain the reason of contact and be very clear about your ask \n\n2. Do not ask direct personal questions or share private/credit card information.
  """


  schema "users" do
    field :email, :string, unique: true, redact: true
    field :social_id, :string
    field :quick_blox_id, :string
    field :image_name, :string
    field :current_city, :string
    field :last_name, :string
    field :gender, :string
    field :login_type, :string
    field :first_name, :string
    field :home_town_city, :string
    field :longitude, :float
    field :school, :string
    field :password, :string, redact: true
    field :current_country, :string
    field :dob, :utc_datetime
    field :age, :integer
    field :language, :string
    field :user_verification_image, :string
    field :dob_full, :string
    field :referral_code, :string, unique: true
    field :latitude, :float
    field :panic_message, :string
    field :user_about, :string
    field :home_town_country, :string
    field :quick_blox_password, :string
    field :friend_code, :string
    field :verification_token, :string
    field :employer, :string
    field :blur_hash, :string
    field :shareable_link, :string
    field :direct_login_link, :string
    field :small_image_name, :string
    field :image_identifier, :integer
    field :user_level, Ecto.Enum, values: [:pending, :unverified, :verified, :exclusive, :staff]
    field :influencer_level, Ecto.Enum, values: [:none, :basic, :standard, :celebrity]
    # Todo move is_* status flags to own table - kebrings
    field :is_deleted, :boolean, default: false, null: false
    field :is_selfie_verified, :boolean, default: false, null: false
    field :is_referral, :boolean, default: false, null: false
    field :is_active, :boolean, default: false, null: false
    field :is_email_verified, :boolean, default: false, null: false
    field :is_deactivated, :boolean, default: false, null: false
    field :is_self_deactivated, :boolean, default: false, null: false

    # GENERATED FIELD (DO NOT POPULATE!) - Feature not properly supported by Ecto. Users.create method must be used so insert is passed through changeset method before inserting.
    # I will look into getting a PR accepted into Ecto to add support for generated: :always|:default columns.
    field :effective_status, Ecto.Enum, values: [:active, :private, :pending, :deactivated, :deleted]

    field :jetzy_exclusive_status, Ecto.Enum, values: [:approved, :pending, :paused, :denied, :review], default: :pending, null: false
    #field :jetzy_exclusive_status_source, Ecto.Enum, values: [:auto, :legacy, :admin], default: :auto, null: :false
    field :jetzy_select_status, Ecto.Enum, values: [:approved, :pending, :paused, :denied, :review], default: :pending, null: false
    #field :jetzy_status_status_source, Ecto.Enum, values: [:auto, :legacy, :admin], default: :auto, null: :false

    has_many :comments, Data.Schema.Comment
    # has_many :comment_likes, Data.Schema.CommentLike
    has_many :report_messages, Data.Schema.ReportMessage
    has_one :user_country, Data.Schema.UserCountry
    has_one :user_emergency_contact, Data.Schema.UserEmergencyContact
    has_one :room_referral_code, Data.Schema.RoomReferralCode
    has_one :user_filters, Data.Schema.UserFilter
    #    has_many :user_follows, Data.Schema.UserFollow
    has_one :user_geo_locations, Data.Schema.UserGeoLocation
    has_many :user_geo_location_logs, Data.Schema.UserGeoLocationLog
    has_many :user_inquiries, Data.Schema.UserInquiry
    has_many :user_interests, Data.Schema.UserInterest
    has_many :user_prefered_interests, Data.Schema.UserPreferedInterest
    has_many :user_prefereces, Data.Schema.UserPreference
    has_many :user_profile_images, Data.Schema.UserProfileImage
    has_many :user_shoutouts, Data.Schema.UserShoutout
    has_many :user_images, Data.Schema.UserImage, where: [is_deleted: false]
    has_many :user_contacts, Data.Schema.UserContact

    many_to_many :user_friends, Data.Schema.UserFriend, join_through: Data.Schema.UserPreferedFriend,
                                                        join_keys: [user_id: :id, friend_id: :id],
                                                        on_replace: :delete
    many_to_many :interests, Data.Schema.Interest, join_through: Data.Schema.UserInterest,
                                                   join_keys: [user_id: :id, interest_id: :id]

    timestamp()

    field :chat_settings, :map, virtual: true

    #followership. variable used in follow query. Data.Context.Users.paginate_users_for_group_chat
    field :followership, :string, virtual: true
    field :distance, :integer, virtual: true
    field :is_local, :boolean, virtual: true
    field :is_traveler, :boolean, virtual: true
    field :is_friend, :boolean, virtual: true
    field :rank, :integer, virtual: true
    field :distance_unit, :string, virtual: true
  end



  @doc """
Refactor copy pasta. - noizu
"""
  def quick_chat_settings(user_id, for_user) do
    followed_status = Data.Context.UserFollows.get_user_followed_status(user_id, for_user.id)
    settings = cond do
                 user_id == for_user.id -> nil # Bug in view own profile page.
                 for_user.user_level == :staff ->
                   # staff may message anyone
                   %{enabled: true, message: nil, etiquette_message: "Don't abuse your position."}
                 followed_status in [:followed, :requested] ->
                   # Other user is following or wants to follow us (for_user)
                   %{enabled: true, message: nil, etiquette_message: @etiquette_message}
                 for_user.user_level == :unverified ->
                   %{enabled: false, message: "You must complete the account verification process to send messages."}
                 :else ->
                   # Check follower status.
                   %{enabled: false, message: "You are not allowed message users who do not follow you."}
               end

  end



  #----------------------------------------------------------------------------
  # get_follow_status\3
  #----------------------------------------------------------------------------
  @doc """
  @todo - copy pasta from user_controller
  """
  def get_follow_status(user, profile_id, current_user_id) do
    is_followed_by_active_user = Data.Context.UserFollows.get_user_following_status(profile_id, current_user_id) || :unfollowed
    is_following_active_user =  Data.Context.UserFollows.get_user_followed_status(profile_id, current_user_id) || :unfollowed

    # Not as with previous logic reading that include :blocked, :cancelled, or mutual requested flags will return nil.
    status_map = %{
      {:followed, :followed} => :mutual_follow,
      {:followed, :unfollowed} => :followed,
      {:unfollowed, :followed} => :other_followed,
      {:followed, :requested} => :other_requested,
      {:unfollowed, :requested} => :other_requested,
      {:requested, :unfollowed} => :requested,
      # special case, this legacy logic is not flexible enough, we need to know that the user has requested to follow us so that we may approve the request but
      # the chat logic needs to know if we (user is following the current user) so that the current user viewing our profile can send us a message
      # App should be updated.
      {:requested, :followed} => :requested, #  they follow us but in this scenario can't message us with legacy logic because we tell the logged in user that they have requested to follow this user but not mentioning this user already follows them and can messaged
      {:requested, :requested} => :other_requested,
    }
    fs = status_map[{is_followed_by_active_user, is_following_active_user}]

    # We really shouldn't be directly manipulating a data record type here as we'll blow away restricted field protections, etc by breaking protocol matching
    user
    |> put_in([Access.key(:follow_status)], fs && "#{fs}") # to string to match previous logic. even though we should be using atoms for logic/matching.
    |> put_in([Access.key(:is_followed_by_active_user)], is_followed_by_active_user)
    |> put_in([Access.key(:is_following_active_user)], is_following_active_user)
  end


  @doc """
    This is a bit hacky due to how follow_status is set upstream. Not entirely sure if all paths to here use same setters to provide this field.
  """
  def set_chat_settings(user, for_user) do
    user = cond do
             Map.get(user, :is_following_active_user) -> user
             v = Map.get(user, :follow_status) ->
               cond do
                 Enum.member?(["requested", :requested], v) ->
                   # in some cases the legacy follow_status may be ambiguous forcing us to use the new logic to resolve the issue.
                   get_follow_status(user, user.id, for_user.id)
                 :else -> user
               end
             :else -> get_follow_status(user, user.id, for_user.id)
           end
    is_following_active_user = Map.get(user, :is_following_active_user)
    follow_status = user.follow_status
    settings = cond do
                 user.id == for_user.id -> nil # Bug in view own profile page.
                 # Catch all in case followed_by wasn't set upstream for some reason - this shouldn't happen.
                 is_following_active_user in [:followed, :requested] ->
                   # Other User is following or requested to follow us so we may message.
                   %{enabled: true, message: nil, etiquette_message: @etiquette_message}
                 is_following_active_user == nil && follow_status in ["other_followed", "mutual_follow", "other_requested", :other_followed, :mutual_follow, :other_requested] ->
                   # Other User is following or requested to follow us so we may message. (legacy logic, new logic users new is_following_active_user field)
                   %{enabled: true, message: nil, etiquette_message: @etiquette_message}
                 for_user.user_level == :unverified ->
                   %{enabled: false, message: "You must complete the account verification process to send messages."}
                 for_user.user_level == :staff ->
                   # Staff may message anyone
                   %{enabled: true, message: nil, etiquette_message: "Don't abuse your position."}
                 :else ->
                   # Check follower status.
                   %{enabled: false, message: "You are not allowed message users who do not follow you."}
               end
    user |> put_in([Access.key(:chat_settings)], settings)
  end

  def credentials(%__MODULE__{} = this, context, options) do
    nil
  end


  def residence(%{__struct__: Data.Schema.User} = record, context, options \\ nil) do
    Jetzy.Location.City.Repo.by_city_country(record.home_town_city, record.home_town_country, context, options)
  end

  def location(%{__struct__: Data.Schema.User} = record, context, options \\ nil) do
    Jetzy.Location.City.Repo.by_city_country(record.current_city, record.current_country, context, options)
  end


  def incomplete_profile?(user) do
    cond do
      is_nil(user.first_name) -> true
      is_nil(user.last_name) -> true
      :else -> false
    end
  end

  #----------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------
  def create_notification_settings(%__MODULE__{id: user_id}) do
    Task.start(fn ->
      notification_type_ids = Data.Context.NotificationTypes.get_notification_type_ids()
      Enum.each(notification_type_ids, fn notification_type_id ->
        case Data.Context.get_by(Data.Schema.NotificationSetting,
               [user_id: user_id, notification_type_id: notification_type_id]) do
          nil -> Data.Context.create(Data.Schema.NotificationSetting,
                   %{
                     user_id: user_id,
                     notification_type_id: notification_type_id,
                     is_send_notification: true,
                     is_send_mail: true
                   })
          _data -> :ok
        end
      end)
    end)
  end


  def create_user_social_login(%__MODULE__{} = _this, "email", _social_login_identifier, _options), do: nil
  def create_user_social_login(%__MODULE__{} = this, login_type, social_login_identifier, options) do
    now = options[:current_time] || DateTime.utc_now()
    social = %{
      type: login_type,
      external_id: social_login_identifier,
      user_id: this.id,
      inserted_at: now,
      updated_at: now
    }
    Data.Context.create(Data.Schema.UserSocialAccount, social)
  end

  #----------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------
  def create_user_settings(%__MODULE__{id: user_id}) do
    case Data.Context.get_by(Data.Schema.UserSetting, [user_id: user_id]) do
      %Data.Schema.UserSetting{} = user_setting -> {:ok, user_setting}
      nil -> Data.Context.create(Data.Schema.UserSetting, %{user_id: user_id})
    end
  end

  #----------------------------------------------------------------------------
  # create_user_image/3
  #----------------------------------------------------------------------------
  def create_user_image(%__MODULE__{} = this, image_name, order_number \\ 1) do
    Data.Context.create(Data.Schema.UserImage, %{
      user_id: this.id,
      images: image_name,
      order_number: order_number
    })
  end

  def create_user_profile_image_extended(%__MODULE__{} = this, {image_identifier, image_name, thumb_name, blur_hash}, order_number \\ 1) do
    Data.Context.create(Data.Schema.UserImage, %{
      user_id: this.id,
      images: image_name,
      image_identifier: image_identifier,
      small_images: thumb_name,
      blur_hash: blur_hash,
      order_number: order_number
    })
  end

  def create_user_profile_image_record(this, image, context, options \\ [])
  def create_user_profile_image_record(_, nil, _, _), do: {:error, :image_upload_error}
  def create_user_profile_image_record(%__MODULE__{} = this, image, context, options) do
    Data.Context.create(Data.Schema.UserImage, %{
      user_id: this.id,
      images: image.image,
      image_identifier: image.identifier,
      small_images: image.thumb,
      blur_hash: image.blur_hash,
      order_number: options[:order_number] || 1
    })
  end


  #----------------------------------------------------------------------------
  # create_user_installs/1
  #----------------------------------------------------------------------------
  def create_user_installs(%__MODULE__{id: user_id} = this, %{"device_token" => device_token} = installs) do
    with nil <- Data.Context.get_by(Data.Schema.UserInstall, device_token: device_token),
         {:ok, data} <- Data.Context.create(Data.Schema.UserInstall, Map.merge(installs, %{"user_id" => user_id})) do
      Data.Context.UserInstalls.get_device_type_and_last_login__clear_cache(user_id)
      {:ok, data}
    else
      %Data.Schema.UserInstall{} = data ->
        r = case Data.Context.update(Data.Schema.UserInstall, data, Map.merge(installs, %{"user_id" => user_id})) do
          {:ok, data} -> {:ok, data}
          {:error, %Ecto.Changeset{} = changeset} ->
            %{error: JetzyModule.CommonModule.decode_changeset_errors(changeset)}
        end
        Data.Context.UserInstalls.get_device_type_and_last_login__clear_cache(user_id)
        r
      {:error, %Ecto.Changeset{} = changeset} ->
        %{error: JetzyModule.CommonModule.decode_changeset_errors(changeset)}
      _ -> {:error, "Something went wrong"}
    end
  end
  def create_user_installs(_this, _) do
    {:ok, "User installs not found"}
  end

  def create_user_role(%__MODULE__{} = this, role) do
    SecureX.Context.create_user_role(%{"user_id" => this.id, "role_id" => role})
  end

  def create_user_settings(%__MODULE__{} = this) do
    case Data.Context.get_by(Data.Schema.UserSetting, [user_id: this.id]) do
      %Data.Schema.UserSetting{} = user_setting -> {:ok, user_setting}
      nil -> Data.Context.create(Data.Schema.UserSetting, %{user_id: this.id})
    end
  end

  def changeset_for_is_active(model, params \\ %{}) do
    model
    |> cast(params, @all_fields -- @generated_fields)
    |> validate_required([:is_active])
  end

  def changeset_for_social(model, params \\ %{}) do
    model
    |> cast(params, @all_fields -- @generated_fields)
  end

  def upsert_changeset(model, params \\ %{}) do
    model
    |> cast(params, [:id] ++ @all_fields -- @generated_fields)
    |> validate_required(@required_fields)
  end

  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @all_fields -- @generated_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email)
    |> unique_constraint(:referral_code, name: :users_referral_code_index)
    |> create_referral()
    |> cast_assoc(:user_contacts)
  end

  @spec create_referral(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp create_referral(%Ecto.Changeset{valid?: true, data: data} = changeset) when data.id == nil do
    referral_code = string_of_length()
    case Data.Context.get_by(Data.Schema.User, [referral_code: referral_code]) do
      nil ->
        change(changeset, referral_code: referral_code)
      _ -> create_referral(changeset)
    end
  end

  defp create_referral(changeset), do: changeset

  @chars "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789" |> String.split("")

  def string_of_length(length \\ 8) do
    Enum.reduce((1..length), [],
      fn (_i, acc) ->
        [Enum.random(@chars) | acc]
      end)
    |> Enum.join("")
  end

  @nmid_index 1048
  use Data.Schema.TanbitsEntity, sref: "t-user"





end
