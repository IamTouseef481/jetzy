#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2021 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.Select.SignUp do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "select-signup"
  @cache {:con_cache, [prime: true, ttl: 600, miss_ttl: 300, fuzzy_ttl: true]}
  @persistence_layer {:mnesia, cascade_block?: true}
  @persistence_layer {:ecto, cascade?: true}
  #@permissions [{[:edit, :view], :user}, {[:view,:index], :restricted}]
  #@index {{:inline, :sphinx}, [type: :real_time, pii: :level_2, default: [{Jetzy.Sphinx.LocationIndex, [anonymize: 5.2]}]]}
  # Pending Implementation: @index {Jetzy.Admin.Index, pii: :level_0}
  defmodule Entity do
    require Logger
    use Amnesia
    @nmid_index 344
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      
      @atom true
      public_field :status
      
      @ref true
      public_field :user
      
      public_field :name
      public_field :referral_code
      public_field :email
      public_field :strategy
      public_field :source
      
      @json_embed {:verbose_mobile, [:created_on, :modified_on, :deleted_on]}
      @json_embed {:mobile, [:created_on, :modified_on, :deleted_on]}
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Second.TypeHandler
    end
    
    #----------------------------
    # __from_record__
    #----------------------------
    def __from_record__(layer, record, context, options \\ nil)
    def __from_record__(_layer, %{__struct__: JetzySchema.Select.SignUp.Table} = record, context, options) do
      %__MODULE__{
        identifier: record.identifier,
        status: record.status,
        user: record.user,
        name: record.name,
        referral_code: record.name,
        email: record.email,
        strategy: record.strategy,
        source: record.source,
        time_stamp: %Noizu.DomainObject.TimeStamp.Second{
          created_on: record.created_on,
          modified_on: record.modified_on,
          deleted_on: record.deleted_on,
        }
      }
    end
    def __from_record__(layer, record, context, options) do
      super(layer, record, context, options)
    end
    
    #----------------------------
    # __from_record__
    #----------------------------
    def __from_record__!(layer, record, context, options \\ nil)
    def __from_record__!(%{__struct__: PersistenceLayer, schema: Data.Repo} = layer, %{__struct__: Data.Schema.User} = record, context, options) do
      Amnesia.async fn ->
        __from_record__(layer, record, context, options)
      end
    end
    def __from_record__!(layer, record, context, options) do
      super(layer, record, context, options)
    end

    def confirmation_email(sign_up, context, options \\ []) do
      context = Noizu.ElixirCore.CallingContext.system(context)
      template = {:jetzy, :select_signup}
      cond do
        !template -> nil
        :else ->
          recipient = %{ref: sign_up.user, name: sign_up.name, email: sign_up.email}
          template = Noizu.EmailService.V3.Email.Template.Entity.entity!(template)
                     |> Noizu.Proto.EmailServiceTemplate.refresh!(Noizu.ElixirCore.CallingContext.system(context))
          user = Noizu.ERP.entity!(sign_up.user)
          bindings = %{
            user: user,
            environment: Jetzy.Email.Helper.email_environment(user),
            sign_up: sign_up
          }
          default_extractor = &Jetzy.Email.Helper.variable_extractor/4
          send_options = %{variable_extractor: default_extractor}
          %Noizu.EmailService.V3.SendGrid.TransactionalEmail{
            template: template,
            recipient: recipient, recipient_email: user.email,
            sender: Jetzy.Email.Helper.default_sender(),
            reply_to: Jetzy.Email.Helper.default_reply(),
            body: " ", html_body: " ", subject: " ",
            bindings: bindings,
          } |> Noizu.EmailService.V3.SendGrid.TransactionalEmail.send!(context, send_options)
      end
    end
    
    #===-------
    # approve
    #===-------
    def approve(this, context, options \\ nil)
    def approve(nil, _, _), do: nil
    def approve(ref, context, options) do
      with {:ok, entity} <- Jetzy.Select.SignUp.Entity.entity_ok!(ref) do
        update = cond do
                   entity.user ->
                     %__MODULE__{entity|
                       status: :approved,
                       time_stamp: %{entity.time_stamp| modified_on: DateTime.utc_now()}
                     } |> Jetzy.Select.SignUp.Repo.update!(context)
                   user = Jetzy.User.Repo.by_email!(entity.email, context, options) ->
                     %__MODULE__{entity|
                       status: :approved,
                       user: Noizu.ERP.ref(user),
                       time_stamp: %{entity.time_stamp| modified_on: DateTime.utc_now()}
                     } |> Jetzy.Select.SignUp.Repo.update!(context)
                   :else ->
                     %__MODULE__{entity|
                       status: :approved,
                       time_stamp: %{entity.time_stamp| modified_on: DateTime.utc_now()}
                     } |> Jetzy.Select.SignUp.Repo.update!(context)
                 end
        with {:ok, user} <- Jetzy.User.Entity.entity_ok!(update.user) do
          Jetzy.Subscription.Repo.add_trial(user, "select-standard", Noizu.ElixirCore.CallingContext.system(), [welcome_email: true])
        end
        update
      end
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

    def pagination_format(%__MODULE__{} = repo) do
      %{
        pagination: %{
          total_rows: repo.length,
          page: 1,
          total_pages: 1,
          page_size: 10_000,
        },
        data: repo.entities,
      }
    end
    
    #------------------------------------
    # by_user!
    #------------------------------------
    def by_user!(user) do
      user = Jetzy.User.Entity.ref(user)
      JetzySchema.Database.Select.SignUp.Table.match!([user: user])
      |> Amnesia.Selection.values()
      |> case do
           [%{entity: e}|_] -> Noizu.ERP.ref(e)
           _ ->
             case JetzySchema.PG.Repo.get_by(JetzySchema.PG.Select.SignUp.Table, [user: UUID.binary_to_string!(Noizu.ERP.id(user))]) do
               %{identifier: identifier} -> Jetzy.Select.SignUp.Entity.ref(UUID.binary_to_string!(identifier))
               _ -> nil
             end
         end
    end


    #-----------------
    # list
    #-------------------
    def list(pagination, filter, _context, _options) do
      # @todo generic logic to query mnesia or ecto, including pagination
      entities = JetzySchema.Database.Select.SignUp.Table.match!([]) |> Amnesia.Selection.values() |> Enum.map(&(&1.entity))
      struct(Jetzy.Select.SignUp.Repo, [pagination: pagination, filter: filter, entities: entities, length: length(entities), retrieved_on: DateTime.utc_now()])
    end

    #-----------------
    # list!
    #-------------------
    def list!(pagination, filter, _context, _options) do
      # @todo generic logic to query mnesia or ecto, including pagination
      entities = JetzySchema.Database.Select.SignUp.Table.match!([]) |> Amnesia.Selection.values() |> Enum.map(&(&1.entity))
      struct(Jetzy.Select.SignUp.Repo, [pagination: pagination, filter: filter, entities: entities, length: length(entities), retrieved_on: DateTime.utc_now()])
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
