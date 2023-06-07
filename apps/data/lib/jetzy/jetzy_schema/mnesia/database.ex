#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

use Amnesia
defdatabase JetzySchema.Database do
  def database(), do: JetzySchema.Database


  def create_handler(%{__struct__: table} = record, _context, _options) do
    table.write(record)
  end

  def create_handler!(%{__struct__: table} = record, _context, _options) do
    table.write!(record)
  end

  def update_handler(%{__struct__: table} = record, _context, _options) do
    table.write(record)
  end

  def update_handler!(%{__struct__: table} = record, _context, _options) do
    table.write!(record)
  end

  def delete_handler(%{__struct__: table} = record, _context, _options) do
    table.delete(record.identifier)
  end

  def delete_handler!(%{__struct__: table} = record, _context, _options) do
    table.delete!(record.identifier)
  end

  #====================================================================
  # Tables
  #====================================================================


  #++++++++++++++++++++++++++++
  # @a
  #++++++++++++++++++++++++++++

  #++++++++++++++++++++++++++++
  # @b
  #++++++++++++++++++++++++++++


  #-----------------------------------------------------------------------------
  # Business
  #-----------------------------------------------------------------------------
  deftable Business.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %Business.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end
  deftable Business.Location.Table, [:identifier, :business, :entity], type: :set, index: [:business] do
    @type t :: %Business.Location.Table{
                 identifier: Types.integer,
                 business: tuple,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # Business.Hotel
  #-----------------------------------------------------------------------------
  deftable Business.Hotel.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %Business.Hotel.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end
  deftable Business.Hotel.Location.Table, [:identifier, :hotel, :entity], type: :set, index: [:hotel] do
    @type t :: %Business.Hotel.Location.Table{
                 identifier: Types.integer,
                 hotel: tuple,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # Business.Restaurant
  #-----------------------------------------------------------------------------
  deftable Business.Restaurant.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %Business.Restaurant.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end
  deftable Business.Restaurant.Location.Table, [:identifier, :restaurant, :entity], type: :set, index: [:restaurant] do
    @type t :: %Business.Restaurant.Location.Table{
                 identifier: Types.integer,
                 restaurant: tuple,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # Business.Vendor
  #-----------------------------------------------------------------------------
  deftable Business.Vendor.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %Business.Vendor.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end
  deftable Business.Vendor.Location.Table, [:identifier, :vendor, :entity], type: :set, index: [:vendor] do
    @type t :: %Business.Vendor.Location.Table{
                 identifier: Types.integer,
                 vendor: tuple,
                 entity: any
               }
  end


  #++++++++++++++++++++++++++++
  # @c
  #++++++++++++++++++++++++++++

  deftable Comment.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Contact.Channel.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %Contact.Channel.Table{
                 identifier: tuple,
                 entity: any
               }
  end

  deftable Channel.Definition.Table, [:identifier, :handle, :entity], type: :set, index: [:handle] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 handle: String.t,
                 entity: any
               }
  end

  deftable Contact.Channel.Field.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %Contact.Channel.Field.Table{
                 identifier: tuple,
                 entity: any
               }
  end

  deftable Channel.Definition.Field.Table, [:identifier, :handle, :entity], type: :set, index: [:handle] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #++++++++++++++++++++++++++++
  # @d
  #++++++++++++++++++++++++++++

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable Degree.Table, [:identifier, :name, :entity], type: :set, index: [:name] do
    @type t :: %__MODULE__{
                 identifier: tuple,
                 name: String.t,
                 entity: any
               }
  end

  deftable Device.Table, [:identifier, :finger_print, :entity], type: :set, index: [:finger_print] do
    @type t :: %__MODULE__{
                 identifier: tuple,
                 finger_print: String.t,
                 entity: any
               }
  end


  #++++++++++++++++++++++++++++
  # @e
  #++++++++++++++++++++++++++++
  deftable Entity.Image.Table, [:identifier, :subject, :entity], type: :set, index: [:subject] do
    @type t :: %Entity.Image.Table{
                 identifier: Types.integer,
                 subject: tuple,
                 entity: any
               }
  end

  deftable Entity.Image.Table.Migrate, [:identifier, :subject, :image, :entity], type: :set, index: [:subject, :image] do
    @type t :: %Entity.Image.Table.Migrate{
                 identifier: Types.integer,
                 subject: tuple,
                 image: tuple,
                 entity: any
               }
  end

  deftable Entity.Reaction.RollUp.Table, [:identifier, :subject, :reaction, :tally, :synchronized_on], type: :set, index: [:subject, :reaction, :tally, :synchronized_on] do
    @type t :: %Entity.Reaction.RollUp.Table{
                 identifier: tuple,
                 subject: tuple,
                 reaction: atom,
                 tally: integer,
                 synchronized_on: integer,
               }
  end

  deftable Entity.Comment.RollUp.Table, [:identifier, :subject, :tally, :synchronized_on], type: :set, index: [:subject,  :tally, :synchronized_on] do
    @type t :: %Entity.Comment.RollUp.Table{
                 identifier: tuple,
                 subject: tuple,
                 tally: integer,
                 synchronized_on: integer,
               }
  end

  deftable Entity.Share.RollUp.Table, [:identifier, :subject, :tally, :synchronized_on], type: :set, index: [:subject,  :tally, :synchronized_on] do
    @type t :: %Entity.Share.RollUp.Table{
                 identifier: tuple,
                 subject: tuple,
                 tally: integer,
                 synchronized_on: integer,
               }
  end

  deftable Entity.Video.Table, [:identifier, :subject, :entity], type: :set, index: [:subject] do
    @type t :: %Entity.Video.Table{
                 identifier: Types.integer,
                 subject: tuple,
                 entity: any
               }
  end

  deftable Entity.Interactions.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %Entity.Interactions.Table{
                 identifier: tuple,
                 entity: any
               }
  end

  deftable Entity.Contact.Channel.Table, [:identifier, :subject, :entity], type: :set, index: [:subject] do
    @type t :: %Entity.Contact.Channel.Table{
                 identifier: tuple,
                 subject: tuple,
                 entity: any
               }
  end

  deftable Entity.Share.Table, [:identifier, :subject, :share, :entity], type: :set, index: [:subject, :share] do
    @type t :: %Entity.Share.Table{
                 identifier: tuple,
                 subject: tuple,
                 share: tuple,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable Entity.Sphinx.Index.State.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %Entity.Sphinx.Index.State.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable Employer.Table, [:identifier, :name, :owner, :entity], type: :set, index: [:name, :owner] do
    @type t :: %__MODULE__{
                 identifier: tuple,
                 name: String.t,
                 owner: tuple,
                 entity: any
               }
  end

  #++++++++++++++++++++++++++++
  # @f
  #++++++++++++++++++++++++++++

  deftable Feature.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: any,
                 entity: any
               }
  end

  deftable Feature.Set.Table, [:identifier, :handle, :entity], type: :set, index: [:handle] do
    @type t :: %__MODULE__{
                 identifier: any,
                 handle: any,
                 entity: any
               }
  end
  
  #++++++++++++++++++++++++++++
  # @g
  #++++++++++++++++++++++++++++

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable Group.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #++++++++++++++++++++++++++++
  # @h
  #++++++++++++++++++++++++++++

  #++++++++++++++++++++++++++++
  # @i
  #++++++++++++++++++++++++++++


  deftable Import.Error.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 entity: any
               }
  end

  deftable Import.Error.Section.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 entity: any
               }
  end

  deftable Import.Error.Table,
           [:identifier, :status, :modified_on, :entity],
           type: :set, index: [:status, :modified_on] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 status: atom,
                 modified_on: any,
                 entity: any,
               }
  end



  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable Image.Table, [:identifier, :uploader, :entity], type: :set, index: [:uploader] do
    @type t :: %Image.Table{
                 identifier: any,
                 uploader: any,
                 entity: any
               }
  end

  deftable Image.Table.Migrate, [:identifier, :uploader, :uuid, :hash, :source, :entity], type: :set, index: [:uploader, :uuid, :hash, :source] do
    @type t :: %Image.Table.Migrate{
                 identifier: Types.integer,
                 uploader: any,
                 uuid: String.t,
                 hash: String.t,
                 source: String.t,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable Interest.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %Interest.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #++++++++++++++++++++++++++++
  # @j
  #++++++++++++++++++++++++++++

  #++++++++++++++++++++++++++++
  # @k
  #++++++++++++++++++++++++++++

  #++++++++++++++++++++++++++++
  # @l
  #++++++++++++++++++++++++++++



  deftable Location.Redirect.Table, [:identifier, :location, :redirect_to, :entity], type: :set, index: [:location, :redirect_to] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 location: any,
                 redirect_to: any,
                 entity: any
               }
  end

  deftable Location.Relation.Table, [:identifier, :location, :location_relation, :location_relation_type, :entity], type: :set, index: [:location, :location_relation, :location_relation_type] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 location: any,
                 location_relation: any,
                 location_relation_type: any,
                 entity: any
               }
  end

  deftable OperatingSystem.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 entity: any
               }
  end

  deftable Post.Interest.Table, [:identifier, :post, :interest, :entity], type: :set, index: [:post, :interest] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 post: any,
                 interest: any,
                 entity: any
               }
  end


  deftable Transaction.Status.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 entity: any
               }
  end


  deftable Entity.Subject.Comment.History.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Entity.Subject.Share.History.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end





  deftable LegacyResolution.Source.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 entity: any
               }
  end

  deftable LegacyResolution.Table,
           [:identifier, :ref, :legacy_source, :legacy_integer_identifier, :legacy_guid_identifier, :legacy_string_identifier, :legacy_sub_identifier],
           type: :set, index: [:ref, :legacy_source, :legacy_integer_identifier, :legacy_guid_identifier, :legacy_string_identifier, :legacy_sub_identifier] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 ref: tuple,
                 legacy_source: tuple,
                 legacy_integer_identifier: integer,
                 legacy_guid_identifier: String.t,
                 legacy_string_identifier: String.t,
                 legacy_sub_identifier: integer
               }
  end


  deftable Locale.Country.Enum.Table, [:identifier, :iso_3166_code, :entity], type: :set, index: [:iso_3166_code] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 iso_3166_code: any,
                 entity: any
               }
  end


  deftable Locale.Language.Enum.Table, [:identifier, :iso_639_code, :entity], type: :set, index: [:iso_639_code] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 iso_639_code: any,
                 entity: any
               }
  end

  deftable Location.Country.Table, [:identifier, :name, :iso_3166_code, :entity], type: :set, index: [:name, :iso_3166_code] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 name: String.t,
                 iso_3166_code: String.t,
                 entity: any
               }
  end

  deftable Location.State.Table, [:identifier, :name, :country, :entity], type: :set, index: [:name, :country] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 name: String.t,
                 country: tuple,
                 entity: any
               }
  end

  deftable Location.City.Table, [:identifier, :name, :state, :country, :entity], type: :set, index: [:name, :state, :country] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 name: String.t,
                 state: tuple,
                 country: tuple,
                 entity: any
               }
  end


  deftable Location.Place.Table, [:identifier, :place_key, :city, :state, :country, :entity], type: :set, index: [:place_key, :city, :state, :country] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 place_key: String.t,
                 city: tuple,
                 state: tuple,
                 country: tuple,
                 entity: any
               }
  end


  #++++++++++++++++++++++++++++
  # @m
  #++++++++++++++++++++++++++++

  #++++++++++++++++++++++++++++
  # @n
  #++++++++++++++++++++++++++++

  #++++++++++++++++++++++++++++
  # @o
  #++++++++++++++++++++++++++++

  #-----------------------------------------------------------------------------
  # Offer.Table
  #-----------------------------------------------------------------------------
  deftable Offer.Table, [:identifier, :tier, :redeem_type, :activity_type, :active_from, :active_until, :entity], type: :set, index: [:tier, :redeem_type, :activity_type, :active_from, :active_until] do
    @type t :: %Offer.Table{
                 identifier: Types.integer,
                 tier: any,
                 redeem_type: any,
                 activity_type: any,
                 active_from: any,
                 active_until: any,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # Offer.Activity
  #-----------------------------------------------------------------------------
  deftable Offer.Activity.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %Offer.Activity.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # Offer.Deal
  #-----------------------------------------------------------------------------
  deftable Offer.Deal.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %Offer.Deal.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #++++++++++++++++++++++++++++
  # @p
  #++++++++++++++++++++++++++++
  deftable Payment.Provider.Table, [:identifier, :entity], type: :set, index: []  do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end
  
  
  deftable Post.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Post.Entity.Tag.Contact.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #++++++++++++++++++++++++++++
  # @q
  #++++++++++++++++++++++++++++

  #++++++++++++++++++++++++++++
  # @r
  #++++++++++++++++++++++++++++

  #-----------------------------------------------------------------------------
  # Reward
  #-----------------------------------------------------------------------------
  deftable Reward.Table, [:identifier, :tier, :redeem_type, :activity_type, :active_from, :active_until, :entity], type: :set, index: [:tier, :redeem_type, :activity_type, :active_from, :active_until] do
    @type t :: %Reward.Table{
                 identifier: Types.integer,
                 tier: any,
                 redeem_type: any,
                 activity_type: any,
                 active_from: any,
                 active_until: any,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # Reward
  #-----------------------------------------------------------------------------
  deftable Reward.Tier.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %Reward.Tier.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Reward.Event.Table, [:identifier, :activity_type, :entity], type: :set, index: [:activity_type] do
    @type t :: %Reward.Event.Table{
                 identifier: Types.integer,
                 activity_type: atom,
                 entity: any
               }
  end
  #++++++++++++++++++++++++++++
  # @s
  #++++++++++++++++++++++++++++


  deftable Select.Reservation.Tracking.Table, [:identifier, :code, :updated_on, :entity], type: :ordered_set, index: [:code, :updated_on] do
    @type t :: %__MODULE__{
                 identifier: any,
                 code: any,
                 updated_on: any,
                 entity: any,
               }
  end
  
  
  deftable Select.SignUp.Table, [:identifier, :user, :email, :status, :created_on, :entity], type: :set, index: [:user, :email, :status, :created_on] do
    @type t :: %__MODULE__{
    identifier: any,
    user: any,
    email: any,
    status: any,
    created_on: any,
    entity: any,
   }
  
  end

  deftable Subscription.Group.Table, [:identifier, :handle, :entity], type: :set, index: [:handle] do
    @type t :: %__MODULE__{
                 identifier: any,
                 handle: String.t,
                 entity: any
               }
  end
  
  deftable Subscription.Table, [:identifier, :handle, :subscription_group, :entity], type: :set, index: [:handle, :subscription_group] do
    @type t :: %__MODULE__{
                 identifier: any,
                 handle: String.t,
                 subscription_group: any,
                 entity: any
               }
  end
  
  deftable System.Event.Table, [:identifier, :system_event_type, :entity], type: :set, index: [:system_event_type] do
    @type t :: %System.Event.Table{
                 identifier: Types.integer,
                 system_event_type: any,
                 entity: any
               }
  end

  deftable Setting.Table, [:identifier, :value], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: atom,
                 value: any
               }
  end

  deftable Social.Type.Enum.Table, [:identifier, :value], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: atom,
                 value: any
               }
  end


  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable School.Table, [:identifier, :name, :owner, :entity], type: :set, index: [:name, :owner] do
    @type t :: %__MODULE__{
                 identifier: tuple,
                 name: String.t,
                 owner: tuple,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable Service.ChatRoom.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable Service.UserManager.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #++++++++++++++++++++++++++++
  # @t
  #++++++++++++++++++++++++++++


  deftable TanbitsResolution.Source.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 entity: any
               }
  end

  deftable TanbitsResolution.Table,
           [:identifier, :ref, :tanbits_source, :tanbits_integer_identifier, :tanbits_guid_identifier, :tanbits_string_identifier, :tanbits_sub_identifier],
           type: :set, index: [:ref, :tanbits_source, :tanbits_integer_identifier, :tanbits_guid_identifier, :tanbits_string_identifier, :tanbits_sub_identifier] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 ref: tuple,
                 tanbits_source: tuple,
                 tanbits_integer_identifier: integer,
                 tanbits_guid_identifier: String.t,
                 tanbits_string_identifier: String.t,
                 tanbits_sub_identifier: integer
               }
  end

  #++++++++++++++++++++++++++++
  # @u
  #++++++++++++++++++++++++++++

  deftable UniversalIdentifierResolution.Table, [:identifier, :ref], type: :set, index: [:ref] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 ref: tuple
               }
  end


  #-----------------------------------------------------------------------------
  # User Tables
  #-----------------------------------------------------------------------------
  deftable User.Table, [:identifier, :email, :entity], type: :set, index: [:email] do
    @type t :: %User.Table{
                 identifier: Types.integer,
                 email: any,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable User.Location.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.ref,
                 entity: any
               }
  end

  deftable User.Location.History.Table, [:identifier, :user, :visibility, :logged_on, :replaced_on, :entity], type: :set, index: [:user, :visibility, :logged_on, :replaced_on] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 user: Types.ref,
                 visibility: atom,
                 logged_on: Types.integer,
                 replaced_on: Types.integer,
                 entity: any
               }
  end

  deftable User.Payment.Provider.Account.Table, [:identifier, :user, :account, :entity], type: :set, index: [:user, :account]  do
    @type t :: %__MODULE__{
                 identifier: any,
                 user: any,
                 account: String.t,
                 entity: any
               }
  end
  
  
  #-----------------------------------------------------------------------------
  # User Tables
  #-----------------------------------------------------------------------------
  deftable User.Interest.Table, [:identifier, :user, :interest, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 user: Types.integer,
                 interest: Types.integer,
                 entity: any
               }
  end


  #-----------------------------------------------------------------------------
  # User Authentication Setting
  #-----------------------------------------------------------------------------
  deftable User.Authentication.Setting.Table, [:identifier, :user, :entity], type: :set, index: [:user] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 user: tuple,
                 entity: any
               }
  end

  deftable User.Device.Table, [:identifier, :user, :entity], type: :set, index: [:user] do
    @type t :: %__MODULE__{
                 identifier: tuple,
                 user: tuple,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # User Credential
  #-----------------------------------------------------------------------------
  deftable User.Credential.Table, [:identifier, :query_key, :entity], type: :set, index: [:query_key] do
    @type t :: %User.Credential.Table{
                 identifier: Types.integer,
                 query_key: tuple,
                 entity: any
               }
  end


  #-----------------------------------------------------------------------------
  # User Session
  #-----------------------------------------------------------------------------
  deftable User.Session.Table, [:identifier, :user, :uuid, :credential, :status, :entity], type: :set, index: [:user, :uuid, :credential, :status] do
    @type t :: %__MODULE__{
                 identifier: tuple,
                 user: tuple,
                 uuid: String.t,
                 status: atom,
                 credential: any,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # User Session Generation
  #-----------------------------------------------------------------------------
  deftable User.Session.Generation.Table, [:identifier, :generation], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: tuple,
                 generation: integer
               }
  end


  deftable User.Subscription.Table, [:identifier, :user, :subscription_definition, :entity], type: :set, index: [:user, :subscription_definition] do
    @type t :: %__MODULE__{
                 identifier: any,
                 user: any,
                 subscription_definition: any,
                 entity: any
               }
  end
  
  #-----------------------------------------------------------------------------
  # User Tables
  #-----------------------------------------------------------------------------
  deftable User.Guid.Lookup.Table, [:identifier, :user, :guid, :status], type: :set, index: [:user, :guid] do
    @type t :: %User.Guid.Lookup.Table{
                 identifier: Types.integer,
                 user: tuple,
                 guid: :string,
                 status: atom
               }
  end

  deftable User.Point.Balance.Table, [:identifier, :user, :at_transaction, :entity], type: :set, index: [:user, :at_transaction] do
    @type t :: %User.Point.Balance.Table{
                 identifier: Types.integer,
                 user: any,
                 at_transaction: any,
                 entity: any
               }
  end


  deftable User.Reward.Table, [:identifier, :user, :item, :entity], type: :set, index: [:user, :item] do
    @type t :: %User.Reward.Table{
                 identifier: Types.integer,
                 user: any,
                 item: any,
                 entity: any
               }
  end

  deftable User.Block.Table, [:identifier, :user, :block, :entity], type: :set, index: [:user, :block] do
    @type t :: %User.Block.Table{
                 identifier: Types.integer,
                 user: any,
                 block: any,
                 entity: any
               }
  end


  deftable User.Block.Lookup.Table, [:identifier, :user, :block, :entity], type: :set, index: [:user, :block] do
    @type t :: %User.Block.Lookup.Table{
                 identifier: Types.integer,
                 user: any,
                 block: any,
                 entity: any
               }
  end


  deftable User.Follow.Table, [:identifier, :user, :follow, :entity], type: :set, index: [:user, :follow] do
    @type t :: %User.Follow.Table{
                 identifier: Types.integer,
                 user: any,
                 follow: any,
                 entity: any
               }
  end


  deftable User.Friend.Table, [:identifier, :user, :friend, :entity], type: :set, index: [:user, :friend] do
    @type t :: %User.Friend.Table{
                 identifier: Types.integer,
                 user: any,
                 friend: any,
                 entity: any
               }
  end


  deftable User.Friend.Lookup.Table, [:identifier, :user, :friend, :entity], type: :set, index: [:user, :friend] do
    @type t :: %User.Friend.Lookup.Table{
                 identifier: Types.integer,
                 user: any,
                 friend: any,
                 entity: any
               }
  end


  deftable User.Friend.Request.Table, [:identifier, :user, :friend, :status, :entity], type: :set, index: [:user, :friend, :status] do
    @type t :: %User.Friend.Request.Table{
                 identifier: Types.integer,
                 user: any,
                 friend: any,
                 status: any,
                 entity: any
               }
  end


  deftable User.Mute.Table, [:identifier, :user, :mute, :entity], type: :set, index: [:user, :mute] do
    @type t :: %User.Mute.Table{
                 identifier: Types.integer,
                 user: any,
                 mute: any,
                 entity: any
               }
  end

  deftable User.Notification.Setting.Table, [:identifier, :user, :notification_type, :entity], type: :set, index: [:user, :notification_type] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 user: any,
                 notification_type: any,
                 entity: any
               }
  end


  deftable User.Notification.Type.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: atom,
                 entity: any
               }
  end


  deftable User.Notification.Event.Table, [:identifier, :notification_type, :entity], type: :set, index: [:notification_type] do
    @type t :: %__MODULE__{
                 identifier: atom,
                 notification_type: atom,
                 entity: any
               }
  end


  deftable User.Relation.Group.Table, [:identifier, :user, :entity], type: :set, index: [:user] do
    @type t :: %User.Relation.Group.Table{
                 identifier: Types.integer,
                 user: any,
                 entity: any
               }
  end


  deftable User.Relation.Table, [:identifier, :user, :relation, :entity], type: :set, index: [:user, :relation] do
    @type t :: %User.Relation.Table{
                 identifier: Types.integer,
                 user: any,
                 relation: any,
                 entity: any
               }
  end



  deftable User.Relative.Table, [:identifier, :user, :relative, :status, :relative_type, :entity], type: :set, index: [:user, :relative, :status, :relative_type] do
    @type t :: %User.Relative.Table{
                 identifier: Types.integer,
                 user: any,
                 relative: any,
                 status: any,
                 relative_type: any,
                 entity: any
               }
  end

  deftable User.Relative.Request.Table, [:identifier, :user, :relative, :relative_type,  :status, :from_user_relative_request, :entity], type: :set, index: [:user, :relative, :relative_type, :status, :from_user_relative_request] do
    @type t :: %User.Relative.Request.Table{
                 identifier: Types.integer,
                 user: any,
                 relative: any,
                 relative_type: any,
                 status: any,
                 from_user_relative_request: any,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable User.Referral.Code.Table, [:identifier, :user, :code, :entity], type: :set, index: [:user, :code] do
    @type t :: %User.Referral.Code.Table{
                 identifier: Types.integer,
                 user: tuple,
                 code: :string,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable User.Referral.Redemption.Table, [:identifier, :user, :referred_user, :user_referral_code, :entity], type: :set, index: [:user, :referred_user, :user_referral_code] do
    @type t :: %User.Referral.Redemption.Table{
                 identifier: Types.integer, # user
                 user: tuple,
                 referred_user: tuple,
                 user_referral_code: tuple,
                 entity: any
               }
  end




  #++++++++++++++++++++++++++++
  # @v
  #++++++++++++++++++++++++++++

  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable Vocation.Table, [:identifier, :name, :entity], type: :set, index: [:name] do
    @type t :: %__MODULE__{
                 identifier: tuple,
                 name: String.t,
                 entity: any
               }
  end

  #++++++++++++++++++++++++++++
  # @w
  #++++++++++++++++++++++++++++

  #++++++++++++++++++++++++++++
  # @x
  #++++++++++++++++++++++++++++

  #++++++++++++++++++++++++++++
  # @y
  #++++++++++++++++++++++++++++

  #++++++++++++++++++++++++++++
  # @z
  #++++++++++++++++++++++++++++




  #=============================================
  #=============================================
  # CMS Tables
  #=============================================
  #=============================================

  #-----------------------------------------------------------------------------
  # @Record.Table
  #-----------------------------------------------------------------------------
  deftable CMS.Article.Table, [:identifier, :ecto_identifier, :entity], type: :set, index: [:ecto_identifier] do
    @type t :: %__MODULE__{
                 identifier: any,
                 ecto_identifier: integer,
                 entity: any
               }
  end # end deftable

  #-----------------------------------------------------------------------------
  # @Article.Index.Table
  #-----------------------------------------------------------------------------
  deftable CMS.Article.Index.Table,
           [:article, :status, :manager, :article_type, :editor, :created_on, :modified_on, :active_version, :active_revision],
           type: :set,
           index: [:status, :manager, :article_type, :editor, :created_on, :modified_on] do
    @type t :: %__MODULE__{
                 article: Noizu.KitchenSink.Types.entity_reference,
                 status: :approved | :pending | :disabled | atom,
                 manager: atom,
                 article_type: :post | :file | :image | :default | atom | any,
                 editor: Noizu.KitchenSink.Types.entity_reference,
                 created_on: integer,
                 modified_on: integer,
                 active_version: any,
                 active_revision: any,
               }
  end # end deftable

  #-----------------------------------------------------------------------------
  # @Article.ActiveTag.Table
  #-----------------------------------------------------------------------------
  deftable CMS.Article.ActiveTag.Table, [:article, :tag], type: :bag, index: [:tag] do
    @type t :: %__MODULE__{
                 article: Noizu.KitchenSink.Types.entity_reference,
                 tag: atom,
               }
  end # end deftable

  #=============================================================================
  #=============================================================================
  # Versioning
  #=============================================================================
  #=============================================================================

  #-----------------------------------------------------------------------------
  # @Article.VersionSequencer.Table
  #-----------------------------------------------------------------------------
  deftable CMS.Article.VersionSequencer.Table, [:identifier, :sequence], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: any, # version ref
                 sequence: any,
               }
  end # end deftable

  #-----------------------------------------------------------------------------
  # @Version.Table
  #-----------------------------------------------------------------------------
  deftable CMS.Article.Version.Table,
           [:identifier, :ecto_identifier, :editor, :status, :created_on, :modified_on, :entity],
           type: :set,
           index: [:ecto_identifier, :editor, :status, :created_on, :modified_on] do
    @type t :: %__MODULE__{
                 identifier: any, # {article ref, path tuple}
                 ecto_identifier: integer,
                 editor: any,
                 status: any,
                 created_on: integer,
                 modified_on: integer,
                 entity: any,
                 # VersionEntity
               }
  end # end deftable

  #-----------------------------------------------------------------------------
  # @RevisionTable
  #-----------------------------------------------------------------------------
  deftable CMS.Article.Version.Revision.Table,
           [:identifier, :ecto_identifier, :editor, :status, :created_on, :modified_on, :entity],
           type: :set,
           index: [:ecto_identifier, :editor, :status, :created_on, :modified_on] do
    @type t :: %__MODULE__{
                 identifier: any, # { {article, version}, revision}
                 ecto_identifier: integer,
                 editor: any,
                 status: any,
                 created_on: any,
                 modified_on: any,
                 entity: any,
               }
  end # end deftable

  #-----------------------------------------------------------------------------
  # @Active.Version.Table
  #-----------------------------------------------------------------------------
  deftable CMS.Article.Active.Version.Table, [:article, :version], type: :set, index: [] do
    @type t :: %__MODULE__{
                 article: any,
                 version: any,
               }
  end # end deftable


  #-----------------------------------------------------------------------------
  # @Active.Version.Table
  #-----------------------------------------------------------------------------
  deftable CMS.Article.Active.Version.Revision.Table, [:version, :revision], type: :set, index: [] do
    @type t :: %__MODULE__{
                 version: any,
                 revision: any,
               }
  end # end deftable


  #=============================================================================
  #=============================================================================
  # Versioned Tables
  #=============================================================================
  #=============================================================================




  #-----------------------------------------------------------------------------
  # UserVersionedString.Table
  #-----------------------------------------------------------------------------
  deftable UserVersionedString.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %UserVersionedString.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # UserAboutVersionedString.Table
  #-----------------------------------------------------------------------------
  deftable UserAboutVersionedString.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %UserAboutVersionedString.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # UserBioVersionedString.Table
  #-----------------------------------------------------------------------------
  deftable UserBioVersionedString.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %UserBioVersionedString.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # UserPanicVersionedString.Table
  #-----------------------------------------------------------------------------
  deftable UserPanicVersionedString.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %UserPanicVersionedString.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # CommentVersionedString.Table
  #-----------------------------------------------------------------------------
  deftable CommentVersionedString.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %CommentVersionedString.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # PostVersionedString.Table
  #-----------------------------------------------------------------------------
  deftable PostVersionedString.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %PostVersionedString.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # CheckInVersionedString.Table
  #-----------------------------------------------------------------------------
  deftable CheckInVersionedString.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %CheckInVersionedString.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # LocationVersionedString.Table
  #-----------------------------------------------------------------------------
  deftable LocationVersionedString.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %LocationVersionedString.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end


  #-----------------------------------------------------------------------------
  # ModerationVersionedString.Table
  #-----------------------------------------------------------------------------
  deftable ModerationVersionedString.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %ModerationVersionedString.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # VersionedActivity.Table
  #-----------------------------------------------------------------------------
  deftable VersionedActivity.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %VersionedActivity.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # VersionedAddress.Table
  #-----------------------------------------------------------------------------
  deftable VersionedAddress.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %VersionedAddress.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # VersionedBusiness.Table
  #-----------------------------------------------------------------------------
  deftable VersionedBusiness.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %VersionedBusiness.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # VersionedDeal.Table
  #-----------------------------------------------------------------------------
  deftable VersionedDeal.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %VersionedDeal.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # VersionedImageString.Table
  #-----------------------------------------------------------------------------
  deftable VersionedImageString.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %VersionedImageString.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # VersionedLink.Table
  #-----------------------------------------------------------------------------
  deftable VersionedLink.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %VersionedLink.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # VersionedName.Table
  #-----------------------------------------------------------------------------
  deftable VersionedName.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %VersionedName.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # VersionedNightLife.Table
  #-----------------------------------------------------------------------------
  deftable VersionedNightLife.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %VersionedNightLife.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #-----------------------------------------------------------------------------
  # VersionedString.Table
  #-----------------------------------------------------------------------------
  deftable VersionedString.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %VersionedString.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end



  deftable CommentVersionedString.History.Table, [:identifier, :comment_versioned_string, :entity], type: :set, index: [:comment_versioned_string] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 comment_versioned_string: any,
                 entity: any
               }
  end

  deftable LocationVersionedString.History.Table, [:identifier, :location_versioned_string, :entity], type: :set, index: [:location_versioned_string] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 location_versioned_string: any,
                 entity: any
               }
  end

  deftable ModerationVersionedString.History.Table, [:identifier, :moderation_versioned_string, :entity], type: :set, index: [:moderation_versioned_string] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 moderation_versioned_string: any,
                 entity: any
               }
  end

  deftable PostVersionedString.History.Table, [:identifier, :post_versioned_string, :entity], type: :set, index: [:post_versioned_string] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 post_versioned_string: any,
                 entity: any
               }
  end

  deftable UserAboutVersionedString.History.Table, [:identifier, :user_about_versioned_string, :entity], type: :set, index: [:user_about_versioned_string] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 user_about_versioned_string: any,
                 entity: any
               }
  end

  deftable UserBioVersionedString.History.Table, [:identifier, :user_bio_versioned_string, :entity], type: :set, index: [:user_bio_versioned_string] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 user_bio_versioned_string: any,
                 entity: any
               }
  end

  deftable UserPanicVersionedString.History.Table, [:identifier, :user_panic_versioned_string, :entity], type: :set, index: [:user_panic_versioned_string] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 user_panic_versioned_string: any,
                 entity: any
               }
  end

  deftable UserVersionedString.History.Table, [:identifier, :user_versioned_string, :entity], type: :set, index: [:user_versioned_string] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 user_versioned_string: any,
                 entity: any
               }
  end

  deftable VersionedAddress.History.Table, [:identifier, :versioned_address, :entity], type: :set, index: [:versioned_address] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 versioned_address: any,
                 entity: any
               }
  end

  deftable VersionedImageString.History.Table, [:identifier, :versioned_image_string, :entity], type: :set, index: [:versioned_image_string] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 versioned_image_string: any,
                 entity: any
               }
  end

  deftable VersionedLink.History.Table, [:identifier, :versioned_link, :entity], type: :set, index: [:versioned_link] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 versioned_link: any,
                 entity: any
               }
  end

  deftable VersionedName.History.Table, [:identifier, :versioned_name, :entity], type: :set, index: [:versioned_name] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 versioned_name: any,
                 entity: any
               }
  end

  deftable VersionedString.History.Table, [:identifier, :versioned_string, :entity], type: :set, index: [:versioned_string] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 versioned_string: any,
                 entity: any
               }
  end







  #-----------------------------------------------------------------------------
  # Lookup Tables
  #-----------------------------------------------------------------------------

  # r = Enum.map(Jetzy.DomainObject.Schema.__noizu_info__(:enum_entities), fn(entity) ->
  # e = String.replace_leading("#{entity}", "Elixir.","")
  # """
  #    deftable #{e}, [:identifier, :entity], type: :set, index: [] do
  #      @type t :: %__MODULE__{
  #                   identifier: Types.integer,
  #                   entity: any
  #                 }
  #    end
  # """
  # end) |> Enum.join("\n")
  # IO.puts r
  # File.write!("database_enum_table.gen", r)



  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable Sphinx.Index.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %Sphinx.Index.Type.Enum.Table{
                 identifier: Types.integer,
                 entity: any
               }
  end
  #-----------------------------------------------------------------------------
  #
  #-----------------------------------------------------------------------------
  deftable UniversalIdentifierResolution.Source.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: integer,
                 entity: any
               }
  end



  deftable Account.Flag.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Achievement.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Activity.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Address.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end


  deftable Business.Attribute.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Business.DressCode.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Business.PricePoint.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Business.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Business.SubType.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Channel.Field.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Channel.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Channel.Handler.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable CheckIn.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  # ------------
  # Extended CMS Functioanlity
  deftable CMS.Article.Attribute.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable CMS.Article.Revision.Attribute.Value.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable CMS.Article.Tag.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable CMS.Article.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end




  deftable Comment.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Comment.Event.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Contact.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Content.Flag.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Credential.Provider.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Credential.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end


  deftable Data.Source.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Data.Source.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Degree.Status.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Degree.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Device.Token.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Device.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Document.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable EmergencyContact.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Employment.Status.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Employment.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Entity.Aspect.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable File.Format.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Friend.Status.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Gender.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Grant.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Group.Grant.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Group.Join.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Group.LookupRule.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Group.Permission.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Group.Permission.Rule.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Group.SignUp.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Image.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end


  deftable Video.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Interaction.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Location.Image.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Location.Relation.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Location.Source.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Location.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Location.Zone.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable ManagedGroup.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Media.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Moderation.Resolution.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Moderation.Status.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Moderation.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Moment.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Notification.Delivery.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Notification.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Offer.Activity.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Offer.Deal.Category.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Offer.Deal.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable OperatingSystem.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Opportunity.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Origin.Source.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Permission.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Post.Content.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Post.Topic.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Post.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Question.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Reaction.Event.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Reaction.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Redeem.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Relationship.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Relative.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable SearchVisibility.Level.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Share.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Share.Event.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable ShoutOut.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Sphinx.Index.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Staff.Role.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable State.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Status.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable System.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable System.Event.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Tag.State.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Tag.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Transaction.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable User.Relation.Group.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable User.Relation.Status.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end


  deftable Session.Status.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  deftable Visibility.Type.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end


  #===============================
  # @JetzySchema.Database.Account.Flag.Entity.Enum.Table
  #===============================
  deftable Account.Flag.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Achievement.Type.Entity.Enum.Table
  #===============================
  deftable Achievement.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Activity.Type.Entity.Enum.Table
  #===============================
  deftable Activity.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Address.Type.Entity.Enum.Table
  #===============================
  deftable Address.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Channel.Type.Entity.Enum.Table
  #===============================
  deftable Channel.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.CheckIn.Type.Entity.Enum.Table
  #===============================
  deftable CheckIn.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.CMS.Article.Attribute.Entity.Enum.Table
  #===============================
  deftable CMS.Article.Attribute.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.CMS.Article.Revision.Attribute.Value.Type.Entity.Enum.Table
  #===============================
  deftable CMS.Article.Revision.Attribute.Value.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.CMS.Article.Tag.Entity.Enum.Table
  #===============================
  deftable CMS.Article.Tag.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.CMS.Article.Type.Entity.Enum.Table
  #===============================
  deftable CMS.Article.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Comment.Type.Entity.Enum.Table
  #===============================
  deftable Comment.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Contact.Type.Entity.Enum.Table
  #===============================
  deftable Contact.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Content.Flag.Entity.Enum.Table
  #===============================
  deftable Content.Flag.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Credential.Provider.Entity.Enum.Table
  #===============================
  deftable Credential.Provider.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Credential.Type.Entity.Enum.Table
  #===============================
  deftable Credential.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Degree.Status.Entity.Enum.Table
  #===============================
  deftable Degree.Status.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Degree.Type.Entity.Enum.Table
  #===============================
  deftable Degree.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Device.Token.Type.Entity.Enum.Table
  #===============================
  deftable Device.Token.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Device.Type.Entity.Enum.Table
  #===============================
  deftable Device.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Document.Type.Entity.Enum.Table
  #===============================
  deftable Document.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.EmergencyContact.Type.Entity.Enum.Table
  #===============================
  deftable EmergencyContact.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Employment.Status.Entity.Enum.Table
  #===============================
  deftable Employment.Status.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Employment.Type.Entity.Enum.Table
  #===============================
  deftable Employment.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Entity.Aspect.Entity.Enum.Table
  #===============================
  deftable Entity.Aspect.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.File.Format.Entity.Enum.Table
  #===============================
  deftable File.Format.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Friend.Status.Entity.Enum.Table
  #===============================
  deftable Friend.Status.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Gender.Entity.Enum.Table
  #===============================
  deftable Gender.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Grant.Type.Entity.Enum.Table
  #===============================
  deftable Grant.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Group.Grant.Type.Entity.Enum.Table
  #===============================
  deftable Group.Grant.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Group.Join.Type.Entity.Enum.Table
  #===============================
  deftable Group.Join.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Group.LookupRule.Entity.Enum.Table
  #===============================
  deftable Group.LookupRule.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Group.Permission.Entity.Enum.Table
  #===============================
  deftable Group.Permission.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Group.Permission.Rule.Entity.Enum.Table
  #===============================
  deftable Group.Permission.Rule.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Group.SignUp.Type.Entity.Enum.Table
  #===============================
  deftable Group.SignUp.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Image.Type.Entity.Enum.Table
  #===============================
  deftable Image.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Interaction.Type.Entity.Enum.Table
  #===============================
  deftable Interaction.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Location.Image.Type.Entity.Enum.Table
  #===============================
  deftable Location.Image.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Location.Relation.Type.Entity.Enum.Table
  #===============================
  deftable Location.Relation.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Location.Source.Entity.Enum.Table
  #===============================
  deftable Location.Source.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Location.Type.Entity.Enum.Table
  #===============================
  deftable Location.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Location.Zone.Entity.Enum.Table
  #===============================
  deftable Location.Zone.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.ManagedGroup.Type.Entity.Enum.Table
  #===============================
  deftable ManagedGroup.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Media.Type.Entity.Enum.Table
  #===============================
  deftable Media.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Moderation.Resolution.Entity.Enum.Table
  #===============================
  deftable Moderation.Resolution.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Moderation.Status.Enum.Entity.Enum.Table
  #===============================
  deftable Moderation.Status.Enum.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Moderation.Type.Entity.Enum.Table
  #===============================
  deftable Moderation.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Moment.Type.Entity.Enum.Table
  #===============================
  deftable Moment.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Notification.Delivery.Type.Entity.Enum.Table
  #===============================
  deftable Notification.Delivery.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Notification.Type.Entity.Enum.Table
  #===============================
  deftable Notification.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.OperatingSystem.Entity.Enum.Table
  #===============================
  deftable OperatingSystem.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Opportunity.Type.Entity.Enum.Table
  #===============================
  deftable Opportunity.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Origin.Source.Entity.Enum.Table
  #===============================
  deftable Origin.Source.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Permission.Entity.Enum.Table
  #===============================
  deftable Permission.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Post.Content.Entity.Enum.Table
  #===============================
  deftable Post.Content.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Post.Topic.Entity.Enum.Table
  #===============================
  deftable Post.Topic.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Post.Type.Entity.Enum.Table
  #===============================
  deftable Post.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Question.Type.Entity.Enum.Table
  #===============================
  deftable Question.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Reaction.Event.Type.Entity.Enum.Table
  #===============================
  deftable Reaction.Event.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Reaction.Type.Entity.Enum.Table
  #===============================
  deftable Reaction.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Redeem.Type.Entity.Enum.Table
  #===============================
  deftable Redeem.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Relationship.Type.Entity.Enum.Table
  #===============================
  deftable Relationship.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Relative.Type.Entity.Enum.Table
  #===============================
  deftable Relative.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.SearchVisibility.Level.Entity.Enum.Table
  #===============================
  deftable SearchVisibility.Level.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.ShoutOut.Type.Entity.Enum.Table
  #===============================
  deftable ShoutOut.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Sphinx.Index.Entity.Enum.Table
  #===============================
  deftable Sphinx.Index.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Staff.Role.Entity.Enum.Table
  #===============================
  deftable Staff.Role.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.State.Entity.Enum.Table
  #===============================
  deftable State.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Status.Entity.Enum.Table
  #===============================
  deftable Status.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.System.Enum.Entity.Enum.Table
  #===============================
  deftable System.Enum.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.System.Event.Type.Entity.Enum.Table
  #===============================
  deftable System.Event.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Tag.State.Entity.Enum.Table
  #===============================
  deftable Tag.State.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Tag.Type.Entity.Enum.Table
  #===============================
  deftable Tag.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Transaction.Type.Entity.Enum.Table
  #===============================
  deftable Transaction.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.User.Relation.Group.Type.Entity.Enum.Table
  #===============================
  deftable User.Relation.Group.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.User.Relation.Status.Entity.Enum.Table
  #===============================
  deftable User.Relation.Status.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end

  #===============================
  # @JetzySchema.Database.Visibility.Type.Entity.Enum.Table
  #===============================
  deftable Visibility.Type.Entity.Enum.Table, [:identifier, :entity], type: :set, index: [] do
    @type t :: %__MODULE__{
                 identifier: Types.integer,
                 entity: any
               }
  end












end
