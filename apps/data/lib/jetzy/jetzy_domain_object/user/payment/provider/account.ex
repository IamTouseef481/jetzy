#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Payment.Provider.Account do
  use Noizu.DomainObject
  @vsn 1.0
  @sref "item"
  @persistence_layer :mnesia
  @persistence_layer {:ecto, [cascade?: true, fallback?: true, cascade_block?: true]}
  @auto_generate false
  defmodule Entity do
    @nmid_index 173
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      public_field :user
      public_field :payment_provider
      public_field :account
      public_field :time_stamp, nil, Noizu.DomainObject.TimeStamp.Millisecond.TypeHandler
    end
    
    #------------------------------
    #
    #------------------------------
    def __from_record__(l = %{schema: JetzySchema.PG.Repo}, entity, context, options) do
      __from_record__!(l, entity, context, options)
    end
    def __from_record__(layer,entity,context,options), do: super(layer, entity, context, options)
    
    #------------------------------
    #
    #------------------------------
    def __from_record__!(_l = %{schema: JetzySchema.PG.Repo}, entity, context, options) do
      if entity do
        entity = %__MODULE__{
          identifier: UUID.string_to_binary!(entity.identifier),
          user: entity.user,
          payment_provider: entity.payment_provider,
          account: entity.account,
          time_stamp: %Noizu.DomainObject.TimeStamp.Millisecond{
            created_on: entity.created_on,
            modified_on: entity.modified_on,
            deleted_on: entity.deleted_on
          }
        }
        # Auto inject
        options_b = update_in(options || [], [JetzySchema.PG.Repo], &(put_in(&1 || [], [:cascade?], false)))
        Jetzy.User.Payment.Provider.Account.Repo.create!(entity, Noizu.ElixirCore.CallingContext.system(context), options_b)
      end
    end
    def __from_record__!(layer,entity,context,options), do: super(layer, entity, context, options)
  end
  
  defmodule Repo do
    require Logger
    # import Ecto.Query, only: [from: 2]
    Noizu.DomainObject.noizu_repo do
    end

    
    def new!(user, payment_provider = :stripe, context) do
      with {:ok, user_entity} <- Jetzy.User.Entity.entity_ok!(user),
           {:ok, user_ref} <- Jetzy.User.Entity.ref_ok(user_entity),
           {:ok, provider_ref} <- Jetzy.Payment.Provider.Entity.ref_ok(payment_provider),
           {:ok, user_name} <- Noizu.ERP.entity_ok!(user_entity.name),
           {:ok, stripe_customer} <- Stripe.Customer.create(%{name: "#{user_name.last}, #{user_name.first}", email: user_entity.email}) do
        context = Noizu.ElixirCore.CallingContext.system(context)
        account = %Jetzy.User.Payment.Provider.Account.Entity{
          identifier: UUID.uuid4() |> UUID.string_to_binary!(),
          user: user_ref,
          payment_provider: provider_ref,
          account: stripe_customer.id,
          time_stamp: Noizu.DomainObject.TimeStamp.Millisecond.now()
        } |> Jetzy.User.Payment.Provider.Account.Repo.create!(context)
        account && {:ok, account}
      end
      rescue error ->
        Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{Exception.format(:error, error, __STACKTRACE__)}")
        {:error, {:exception, error}}
      catch
      :exit, error ->
        Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{Exception.format(:error, error, __STACKTRACE__)}")
        {:error, {:exception, error}}
      error ->
        Logger.error("[#{__MODULE__}:#{__ENV__.line}] Error #{Exception.format(:error, error, __STACKTRACE__)}")
        {:error, {:exception, error}}
    end
  
  
    def by_account(account, payment_provider, context) do
      with {:ok, provider_ref} <- Jetzy.Payment.Provider.Entity.ref_ok(payment_provider) do
        p = JetzySchema.Database.User.Payment.Provider.Account.Table.match!([account: account])
            |> Amnesia.Selection.values()
            |> Enum.map(&(&1.entity))
            |> Enum.filter(&(&1.payment_provider == provider_ref))
        case p do
          [a|_] -> a
          _ -> nil
        end
      else
        _ -> nil
      end
    end
    
    def by_user!(user, payment_provider, _context) do
      with {:ok, provider_ref} <- Jetzy.Payment.Provider.Entity.ref_ok(payment_provider),
           {:ok, user_ref} <- Jetzy.User.Entity.ref_ok(user) do
        p = JetzySchema.Database.User.Payment.Provider.Account.Table.match!([user: user_ref])
            |> Amnesia.Selection.values()
            |> Enum.map(&(&1.entity))
            |> Enum.filter(&(&1.payment_provider == provider_ref))
        case p do
          [a|_] -> a
          _ -> nil
        end
      else
       _ -> nil
      end
    end # end by_user!
  end
end
