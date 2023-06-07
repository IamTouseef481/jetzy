#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "user"
  @cache {:con_cache, [prime: true, ttl: 600, miss_ttl: 300, fuzzy_ttl: true]}
  @persistence_layer {:mnesia, [cascade?: true, fallback?: true, cascade_block?: true]}
  @persistence_layer {:ecto, [cascade?: true, fallback?: true, cascade_block?: true]}
  @persistence_layer {Data.Repo, Data.Schema.User, [cascade?: false, fallback?: true, cascade_block?: true]}
  #@permissions [{[:edit, :view], :user}, {[:view,:index], :restricted}]
  #@index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: 5.2]}]]}
  # Pending Implementation: @index {Jetzy.Admin.Index, pii: :level_0}
  defmodule Entity do
    require Logger
    use Amnesia
    @nmid_index 126
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      @pii :level_3
      identifier :uuid

      @pii :level_2
      @index true
      restricted_field :name, nil, Jetzy.VersionedName.TypeHandler
      
      @pii :level_2
      @index true
      restricted_field :email

      @pii :level_2
      public_field :profile_image, nil, Jetzy.Entity.Image.TypeHandler

      @ref Jetzy.Entity.Interactions.Entity
      public_field :interactions, nil, Jetzy.Entity.Interactions.TypeHandler

      @pii :level_2
      @index true
      @json_ignore :mobile
      restricted_field :about, nil, Jetzy.UserAboutVersionedString.TypeHandler

      @pii :level_2
      @index true
      @json_ignore :mobile
      restricted_field :bio, nil, Jetzy.UserBioVersionedString.TypeHandler

      @pii :level_2
      @index true
      @json_ignore :mobile
      restricted_field :panic, nil, Jetzy.UserPanicVersionedString.TypeHandler


      @pii :level_2
      @index true
      @json_ignore :mobile
      restricted_field :employer, nil, Jetzy.Employer.TypeHandler

      @pii :level_2
      @index true
      @json_ignore :mobile
      restricted_field :vocation, nil, Jetzy.Vocation.TypeHandler

      @pii :level_2
      @index true
      @json_ignore :mobile
      restricted_field :school, nil, Jetzy.School.TypeHandler

      @pii :level_2
      @index true
      @json_ignore :mobile
      restricted_field :degree, nil, Jetzy.Degree.TypeHandler

      @pii :level_5
      @index {:with, JetzySchema.Types.Gender.Enum}
      restricted_field :gender

      @pii :level_2
      #@index true
      restricted_field :residence, nil, Jetzy.Location.City.TypeHandler

      @pii :level_3
      #@index true
      restricted_field :location, nil, Jetzy.Location.City.TypeHandler

      @pii :level_4
      @index true
      restricted_field :date_of_birth, nil,  Noizu.DomainObject.DateTime.Second.TypeHandler

      @pii :level_5
      @index {:with, JetzySchema.Types.Origin.Source.Enum}
      restricted_field :origin

      @index {:with, Noizu.AdvancedScaffolding.Sphinx.Type.Bool}
      public_field :verified

      public_field :status, :active

      @json_ignore :mobile
      restricted_field :interests, nil, Jetzy.User.Interest.Repo.TypeHandler

      # Ephemeral Section
      @json_ignore :*
      restricted_field :credentials, nil, Jetzy.User.Credential.Repo.TypeHandler

      @json_ignore :*
      restricted_field :channels, nil, Jetzy.Entity.Contact.Channel.Repo.TypeHandler

      # Moderation & Time Stamps
      @index true
      @json_ignore [:verbose_mobile, :mobile]
      public_field :moderation, nil, Jetzy.ModerationDetails.TypeHandler

      @index true
      @json_ignore :*
      @json_embed {:verbose_mobile, [:created_on, :modified_on]}
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end


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

    

    def ref(%Data.Schema.User{} = record), do: ref(record.id && UUID.string_to_binary!(record.id))
    def ref(ref), do: super(ref)
    def ref_ok(%Data.Schema.User{} = record), do: ref_ok(record.id && UUID.string_to_binary!(record.id))
    def ref_ok(ref), do: super(ref)


    def name(user) do
      with {:ok, entity} <- entity_ok!(user),
           {:ok, name} <- Noizu.ERP.entity_ok!(entity.name) do
        name
      end
    end
    
    def first_name(user) do
      with {:ok, entity} <- entity_ok!(user),
           {:ok, name} <- Noizu.ERP.entity_ok!(entity.name) do
        name.first
      end
    end
    def last_name(user) do
      with {:ok, entity} <- entity_ok!(user),
           {:ok, name} <- Noizu.ERP.entity_ok!(entity.name) do
        name.last
      end
    end
    
    
    def existing(<<guid::binary-size(16)>>, context, options) do
      options_b = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:fallback?], false)))
      Jetzy.User.Repo.get!(guid, context, options_b)
    end
    def existing(<<_,_,_,_,_,_,_,_,?-,_,_,_,_,?-,_,_,_,_,?-,_,_,_,_,?-,_,_,_,_,_,_,_,_,_,_,_,_>> = guid, context, options) do
      options_b = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:fallback?], false)))
      Jetzy.User.Repo.get!(UUID.string_to_binary!(guid), context, options_b)
    end
    
    
    def import_name(record, existing, context, _options) do
      first_name = Jetzy.Helper.get_sanitized_string(record.first_name || "", :first_name, existing, record, context)
      last_name = Jetzy.Helper.get_sanitized_string(record.last_name || "", :last_name, existing, record, context)
      name = cond do
               existing_name = Noizu.ERP.entity(existing && existing.name) -> %Jetzy.VersionedName.Entity{existing_name| first: first_name, middle: nil, last: last_name }
               :else -> %{first: first_name, middle: nil, last: last_name}
             end
    end

    def import_about(record, existing, context, _options) do
      user_about = Jetzy.Helper.get_sanitized_string(record.user_about || "", :about, existing, record, context)
      cond do
        vstr = Noizu.ERP.entity(existing && existing.about) -> %Jetzy.UserAboutVersionedString.Entity{vstr|  body: user_about}
        :else -> %{title: "", body: user_about}
      end
    end

    def import_panic(record, existing, context, _options) do
      user_panic = Jetzy.Helper.get_sanitized_string(record.panic_message || "", :panic, existing, record, context)
      cond do
        vstr = Noizu.ERP.entity(existing && existing.panic) -> %Jetzy.UserPanicVersionedString.Entity{vstr|  body: user_panic}
        :else -> %{title: "", body: user_panic}
      end
    end

    def import_school(record, existing, context, options) do
      user_school = Jetzy.Helper.get_sanitized_string(record.school, :school, existing, record, context)
      case user_school && Jetzy.School.Repo.by_name!(user_school, context, options) do
        v = %Jetzy.School.Entity{} -> Noizu.ERP.ref(v)
        _ ->
          case user_school do
            nil -> nil
            "" -> nil
            _ -> %{title: user_school, body:  ""}
          end
      end
    end

    def import_employer(record, existing, context, options) do
      user_employer = Jetzy.Helper.get_sanitized_string(record.employer, :employer, existing, record, context)
      case user_employer && Jetzy.Employer.Repo.by_name!(user_employer, context, options) do
        v = %Jetzy.Employer.Entity{} -> Noizu.ERP.ref(v)
        _ ->
          case user_employer do
            nil -> nil
            "" -> nil
            _ -> %{title: user_employer, body: ""}
          end
      end
    end

    def default_profile_image() do
      Data.Context.DefaultProfileImages.get_random()
      case Jetzy.Helper.get_cached_setting(:default_profile_images, []) |> Enum.take_random(1) do
        [h] -> h
        _ -> nil
      end
    end

    @sort_credentials %{
      Jetzy.User.Credential.JetzyBCrypt => 1,
      Jetzy.User.Credential.JetzyLegacy => 2,
      Jetzy.User.Credential.Firebase => 3,
      Jetzy.User.Credential.JetzyLegacySession => 4,
    }
    def login_name(user, _context, _options) do
      ref = Jetzy.User.Entity.ref(user)
      credentials = JetzySchema.Database.User.Credential.Table.match!([user: ref])
                    |> Amnesia.Selection.values()
                    |> Enum.sort(fn(a,b) ->
                                   a = @sort_credentials[a.entity.settings.__struct__]
                                   b = @sort_credentials[b.entity.settings.__struct__]
                                   cond do
                                     a == b -> 0
                                     a < b -> -1
                                     a > b -> 1
                                   end
      end)
      case credentials do
        [c|_] ->
          case c.settings do
            v = %{__struct__: Jetzy.User.Credential.JetzyBCrypt} ->
              v.login
            v = %{__struct__: Jetzy.User.Credential.JetzyLegacy} ->
              v.login_name
            _ -> nil
          end
        _ -> nil
      end
    end

    # query, cand call expand entities to load interest type
    def interests(_user, _context, _options), do: []
    
    #----------------------------
    # __from_record__
    #----------------------------
    def __from_record__(layer, record, context, options \\ nil)
    def __from_record__(_layer, %{__struct__: JetzySchema.PG.User.Table} = record, context, options) do
      %__MODULE__{
        identifier: UUID.string_to_binary!(record.identifier),
        name: record.name,
        email: record.email,
        interactions: %{},
        profile_image: record.profile_image,
        about: record.about,
        bio: record.bio,
        panic: record.panic,
        school: record.school,
        employer: record.employer,
        gender: record.gender,
        #residence: record.residence,
        #location: record.location,
        date_of_birth: record.date_of_birth,
        origin: record.origin,
        verified: record.verified,
        status: record.status,
        moderation: %Jetzy.ModerationDetails{}, # pending
        time_stamp: Noizu.DomainObject.TimeStamp.Second.import(record.created_on, record.modified_on, record.deleted_on),
      }
#      options_b = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:cascade?], false)))
#                  |> update_in([JetzySchema.PG.Repo], &(put_in(&1||[], [:cascade?], false)))
#                  |> put_in([:override_identifier], true)
#      Jetzy.User.Repo.create!(entity, Noizu.ElixirCore.CallingContext.system(context), options_b)
    end
    def __from_record__(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, %{__struct__: Data.Schema.User} = record, context, options) do
      now = options[:current_time] || DateTime.utc_now()
      options_b = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:fallback?], false)))
      Jetzy.User.Repo.get(record.id, context, options_b)
      
      existing = existing(record.id, context, options)
      name = import_name(record, existing, context, options)
      about = import_about(record, existing, context, options)
      panic = import_panic(record, existing, context, options)
      school = import_school(record, existing, context, options)
      employer = import_employer(record, existing, context, options)
      profile_image = existing && existing.profile_image || Jetzy.Entity.Image.Repo.by_path(record.image_name, context, options)
      interactions = %{} # TODO load
      residence = options[:load][:residence] && Data.Schema.User.residence(record, context, options) || (existing && existing.residence) || nil
      location = options[:load][:location] &&  Data.Schema.User.location(record, context, options) || (existing && existing.location) || nil
      gender = case record.gender do
                "Female" -> :female
                "female" -> :female
                :female -> :female
                 "Male" -> :male
                "male" -> :maile
                :male -> :male
                _ ->
                  existing && existing.gender || :other
               end
      status = record.effective_status
      data_migration = %{
        guid: record.id,
        longitude: record.longitude,
        latitude: record.latitude,
        is_referral: record.is_referral,
        referral_code: record.referral_code,
        friend_code: record.friend_code
      }
      entity = %Jetzy.User.Entity{(existing || %Jetzy.User.Entity{}) |
        identifier: UUID.string_to_binary!(record.id),
        name: name,
        email: record.email,
        interactions: interactions,
        profile_image: profile_image,
        about: about,
        bio: existing && existing.bio,
        panic: panic,
        school: school,
        employer: employer,
        gender: gender,
        residence: residence,
        location: location,
        date_of_birth: record.dob,
        origin: existing && existing.origin || :tanbits,
        verified: record.is_email_verified || existing && existing.verified || false,
        status: status,
        moderation: existing && existing.moderation || %Jetzy.ModerationDetails{},
        time_stamp: Noizu.DomainObject.TimeStamp.Second.import(record.updated_at, record.inserted_at, record.is_deleted && (record.deleted_at || now) || nil),
        __transient__: %{partials: true, data_migration: data_migration, tanbits: record, existing: existing, guid: record.id},
        meta: [guid: record.id, source: :tanbits]
      }
      
      # Repopulate layers automatically, exclude Data.Repo table as we just loaded from this source.
      options_c = update_in(options || [], [Data.Repo], &(put_in(&1||[], [:cascade?], false)))
                  |> put_in([:override_identifier], true)
      Jetzy.User.Repo.create!(entity, Noizu.ElixirCore.CallingContext.system(context), options_c)
    end
    def __from_record__(layer, record, context, options) do
      super(layer, record, context, options)
    end

    #----------------------------
    # __from_record__
    #----------------------------
    def __from_record__!(layer, record, context, options \\ nil)
    def __from_record__!(%{__struct__: PersistenceLayer, schema: JetzySchema.PG.Repo} = layer, %{__struct__: JetzySchema.PG.User.Table} = record, context, options) do
      Amnesia.async fn ->
        __from_record__(layer, record, context, options)
      end
    end
    def __from_record__!(%{__struct__: PersistenceLayer, schema: Data.Repo} = layer, %{__struct__: Data.Schema.User} = record, context, options) do
      Amnesia.async fn ->
        __from_record__(layer, record, context, options)
      end
    end
    def __from_record__!(layer, record, context, options) do
      super(layer, record, context, options)
    end
    

    #===-------
    # has_permission?
    #===-------
    def has_permission?(_entity, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_entity, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

    #===-------
    # has_permission!
    #===-------
    def has_permission!(_entity, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_entity, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true
  end

  defmodule Repo do
    #import Ecto.Query, only: [from: 2]
    require Logger
    Noizu.DomainObject.noizu_repo do

    end

    #----------------------------
    # layer_create_callback
    #----------------------------
    def layer_create_callback(%{__struct__: PersistenceLayer, schema: JetzySchema.Database} = layer, entity, context, options), do: layer_post_create_callback!(layer, entity, context, options)
    def layer_create_callback(layer, entity, context, options), do: super(layer, entity, context, options)


    def extract_channel_email(entity, context, options) do
      with %Jetzy.Entity.Contact.Channel.Repo{entities: channels} <- entity.channels do
        Enum.find_value(channels || [], fn(x) ->
          case channel = Noizu.ERP.entity!(x) do
              %{channel_type: :email, channel: channel} ->
              if c = Noizu.ERP.entity!(channel) do
                Enum.find_value(c.fields.entities || [], fn(y) ->
                  y = Noizu.ERP.entity!(y)
                  y.channel_definition_field == :email && y.value
                end)
              end
              _ -> nil
          end
        end)
      end
    end

    def extract_channel_email_verified(entity, context, options) do
      with %Jetzy.Entity.Contact.Channel.Repo{entities: channels} <- entity.channels do
        Enum.find_value(channels || [], fn(x) ->
          case channel = Noizu.ERP.entity!(x) do
            %{channel_type: :email, channel: channel} ->
              if c = Noizu.ERP.entity!(channel) do
                Enum.find_value(c.fields.entities || [], fn(y) ->
                  y = Noizu.ERP.entity!(y)
                  y.channel_definition_field == :verified && y.value
                end)
              end
            _ -> nil
          end
        end)
      end |> case do
              nil -> false
              "false" -> false
              "true" -> true
             end
    end

    def extract_channel_quickblox_user(entity, context, options) do
      with %Jetzy.Entity.Contact.Channel.Repo{entities: channels} <- entity.channels do
        Enum.find_value(channels || [], fn(x) ->
          case channel = Noizu.ERP.entity!(x) do
            %{channel_type: :quick_blox, channel: channel} ->
              if c = Noizu.ERP.entity!(channel) do
                Enum.find_value(c.fields.entities || [], fn(y) ->
                  y = Noizu.ERP.entity!(y)
                  y.channel_definition_field == :quick_blox_user && y.value
                end)
              end
              _ -> nil
          end
        end)
      end
    end

    def extract_channel_quickblox_auth(entity, context, options) do
      with %Jetzy.Entity.Contact.Channel.Repo{entities: channels} <- entity.channels do
        Enum.find_value(channels || [], fn(x) ->
          case channel = Noizu.ERP.entity!(x) do
            %{channel_type: :quick_blox, channel: channel} ->
              if c = Noizu.ERP.entity!(channel) do
                Enum.find_value(c.fields.entities || [], fn(y) ->
                  y = Noizu.ERP.entity!(y)
                  y.channel_definition_field == :quick_blox_auth && y.value
                end)
              end
              _ -> nil
          end
        end)
      end
    end

    def extract_social_credentials(entity, context, options) do
      with %Jetzy.User.Credential.Repo{entities: credentials} <- entity.credentials do
        Enum.find_value(credentials || [], fn(x) ->
          case credential = Noizu.ERP.entity!(x) do
            %{credential_type: :social, settings: settings} -> settings
            _ -> nil
          end
        end)
      end
    end

    #----------------------------
    # layer_create
    #----------------------------
    def layer_create!(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do
      identifier = entity.__transient__[:guid] || UUID.uuid4
      email = extract_channel_email(entity, context, options)
      email_verified = extract_channel_email_verified(entity, context, options)
      qb_user = extract_channel_quickblox_user(entity, context, options)
      qb_auth = extract_channel_quickblox_auth(entity, context, options)
      social_credential = extract_social_credentials(entity, context, options)
      panic = Jetzy.UserPanicVersionedString.Entity.body(entity.panic)
      about = Jetzy.UserAboutVersionedString.Entity.body(entity.about)
      school = case Noizu.ERP.entity!(entity.school) do
                 %Jetzy.School.Entity{name: name} -> name
                 _ -> ""
               end
      employer = case Noizu.ERP.entity!(entity.employer) do
                   %Jetzy.Employer.Entity{name: name} -> name
                   _ -> ""
                 end
      age = entity.date_of_birth && Timex.diff(DateTime.utc_now(), entity.date_of_birth, :years)
      password = entity.credentials && entity.credentials.__transient__.password && Bcrypt.hash_pwd_salt(entity.credentials.__transient__.password)

      login_type = social_credential && "#{social_credential.social_type}}" || "email"
      social_identifier = social_credential && social_credential.social_identifier || nil
      language = "english"
      {image_identifier, image_name,thumb_name, blur_hash} = Jetzy.Entity.Image.Entity.image_thumb_hash(entity.profile_image, context, options)
      {home_town_city, _, home_town_country} = Jetzy.VersionedAddress.Entity.city_state_country(entity.residence, context, options)
      {current_city, _, current_country} = Jetzy.VersionedAddress.Entity.city_state_country(entity.location, context, options)
      migration = entity.__transient__[:data_migration]

      # unsupported
      user_verification_image = nil # <- @todo need to import and add to extended User entity details.
      is_selfie_verified = false
      dob_full = nil # Don't use user provided string. Localize from DOB timestamp.
      verification_token = nil # <- what is this email code?

      name = Noizu.ERP.entity!(entity.name)

      changes = %{
        id: identifier,
        deleted_at: entity.time_stamp.deleted_on,
        is_deleted: entity.time_stamp.deleted_on && true || false,
        email: email,
        social_id: social_identifier,
        quick_blox_id: qb_user,

        last_name: name && name.last,
        gender: "#{entity.gender}",
        first_name: name && name.first,

        login_type: login_type,
        image_identifier: image_identifier,
        image_name: image_name,
        small_image_name: thumb_name,
        blur_hash: blur_hash,

        home_town_city: home_town_city,
        home_town_country: home_town_country,

        current_city: current_city,
        current_country: current_country,

        latitude: migration[:latitude],
        longitude: migration[:longitude],

        school: school,
        password: password,

        dob: entity.date_of_birth,
        dob_full: dob_full,
        age: age,

        language: language,
        is_selfie_verified: is_selfie_verified,
        user_verification_image: user_verification_image,
        is_referral: migration[:is_referral],
        referral_code: migration[:referral_code],

        is_email_verified: email_verified,

        is_deactivated: entity.status != :active,

        panic_message: panic,
        user_about: about,

        quick_blox_password: qb_auth,
        is_active: entity.status == :active,
        friend_code: migration[:friend_code],
        verification_token: verification_token,
        employer: employer
      }
      changeset = Data.Schema.User.upsert_changeset(%Data.Schema.User{}, changes)
      with  {:ok, record} <- Data.Repo.upsert(changeset) do
        # User Social
        Data.Schema.User.create_user_social_login(record, login_type, social_identifier, options)
        # User Profile Image
        Data.Schema.User.create_user_profile_image_extended(record, {image_identifier, image_name, thumb_name, blur_hash}, 1)
        # User Roles
        Data.Schema.User.create_user_role(record, "user")
        # User Settings
        Data.Schema.User.create_user_settings(record)
        else error ->
          Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{inspect error, pretty: true}")
          error
      end
      entity
    end
    def layer_create!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end

    #----------------------------
    # layer_update
    #----------------------------
    def layer_update(%{__struct__: PersistenceLayer, schema: Data.Repo} = layer, entity, context, options) do
      layer_update!(layer, entity, context, options)
    end
    def layer_update(layer, entity, context, options) do
      super(layer, entity, context, options)
    end

    #----------------------------
    # layer_create
    #----------------------------
    def layer_update!(%{__struct__: PersistenceLayer, schema: Data.Repo} = _layer, entity, context, options) do
      # Pending
      entity
    end
    def layer_update!(layer, entity, context, options) do
      super(layer, entity, context, options)
    end

    #------------------------------------
    # by_guid
    #------------------------------------
    def by_guid(guid, context, options \\ nil), do: get(UUID.binary_to_string!(guid), context, options)

    #------------------------------------
    # by_guid!
    #------------------------------------
    def by_guid!(guid, context, options \\ nil), do: get!(UUID.binary_to_string!(guid), context, options)
    
    #------------------------------------
    # by_email!
    #------------------------------------
    def by_email!(email, _context, _options) when is_bitstring(email) do
      case JetzySchema.PG.Repo.get_by(JetzySchema.PG.User.Table, [email: email]) do
        %{identifier: identifier} -> Jetzy.User.Entity.ref(UUID.binary_to_string!(identifier))
        _ ->
          case Data.Repo.get_by(Data.Schema.User, [email: email]) do
            %{id: identifier} -> Jetzy.User.Entity.ref(UUID.binary_to_string!(identifier))
            _ -> nil
          end
      end
    end
    
    #-----------------
    # list
    #-------------------
    def list(pagination, filter, _context, _options) do
      # @todo generic logic to query mnesia or ecto, including pagination
      entities = JetzySchema.Database.User.Table.match!([]) |> Amnesia.Selection.values() |> Enum.map(&(&1.entity))
      struct(Jetzy.User.Repo, [pagination: pagination, filter: filter, entities: entities, length: length(entities), retrieved_on: DateTime.utc_now()])
    end

    #-----------------
    # list!
    #-------------------
    def list!(pagination, filter, _context, _options) do
      # @todo generic logic to query mnesia or ecto, including pagination
      entities = JetzySchema.Database.User.Table.match!([]) |> Amnesia.Selection.values() |> Enum.map(&(&1.entity))
      struct(Jetzy.User.Repo, [pagination: pagination, filter: filter, entities: entities, length: length(entities), retrieved_on: DateTime.utc_now()])
    end

    #===-------
    # has_permission?
    #===-------
    def has_permission?(_, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_, %Noizu.ElixirCore.CallingContext{}, _options), do: true
    def has_permission?(_repo, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission?(_repo, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true

    #===-------
    # has_permission!
    #===-------
    def has_permission!(_, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_, %Noizu.ElixirCore.CallingContext{}, _options), do: true
    def has_permission!(_repo, _permission, %Noizu.ElixirCore.CallingContext{}), do: true
    def has_permission!(_repo, _permission, %Noizu.ElixirCore.CallingContext{}, _options), do: true
  end

end
