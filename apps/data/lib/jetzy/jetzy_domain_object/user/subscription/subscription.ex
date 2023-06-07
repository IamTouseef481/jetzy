#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 JetzyApp. All rights reserved.
#-------------------------------------------------------------------------------

defmodule Jetzy.User.Subscription do
  use Noizu.DomainObject
  @vsn 1.1
  @sref "subscription"
  @persistence_layer :mnesia
  defmodule Entity do
    @nmid_index 167
    @universal_identifier true
    Noizu.DomainObject.noizu_entity do
      identifier :uuid
      @ref true
      public_field :user
      @ref true
      public_field :subscription_definition
      public_field :payment_type
      public_field :details
      public_field :status
      public_field :status_updated_on
      public_field :coverage_start
      public_field :coverage_end
    end
    
    def get_management_link(this, _context, _options \\ nil) do
      with {:ok, this} <- entity_ok!(this) do
          case this.payment_type do
            :stripe_checkout ->
              return_url = Jetzy.Email.Helper.select_website() <> "/account"
              with {:ok, pa} <- Jetzy.User.Payment.Provider.Account.Entity.entity_ok!(this.details[:stripe_account]),
                   #{:ok, s} <- Stripe.Subscription.retrieve(subscription),
                   {:ok, b} <- Stripe.BillingPortal.Session.create(%{customer: pa.account, return_url: return_url}) |> IO.inspect(label: :portal) do
                {:ok, b.url}
              else
                e -> e
              end
            _ -> {:error, :unsupported}
          end
      else
        e -> e
      end
    end
    
    def payment_type(this) do
      with {:ok, this} <- entity_ok!(this) do
        this.payment_type
      else
        _ -> :error
      end
    end

    def welcome_email(user, trial, context, options) do
      context = Noizu.ElixirCore.CallingContext.system(context)
      template = cond do
                   trial.subscription_definition == Jetzy.Subscription.Repo.by_handle("select-standard") -> {:jetzy, :select_approved}
                   :else -> nil
                 end
      cond do
        !template -> nil
        :else ->
          name = Jetzy.User.Entity.name(user)
          recipient = %{ref: trial.user, name: "#{name && name.last || "___"}, #{name && name.first || "___"}", email: user.email}
          template = Noizu.EmailService.V3.Email.Template.Entity.entity!(template)
                     |> Noizu.Proto.EmailServiceTemplate.refresh!(Noizu.ElixirCore.CallingContext.system(context))
          bindings = %{
            user: user,
            environment: Jetzy.Email.Helper.email_environment(user),
            subscription: trial
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
    
  end
  
  defmodule Repo do
    # import Ecto.Query, only: [from: 2]
    Noizu.DomainObject.noizu_repo do
    
    
    
    end

    #--------------------------------
    #
    #--------------------------------
    def update_vsn(%{vsn: 1.0} = entity, context, options) do
      entity
      |> put_in([Access.key(:payment_type)], :gift)
      |> put_in([Access.key(:details)], %{})
      |> put_in([Access.key(:status_updated_on)], DateTime.utc_now())
      |> put_in([Access.key(:vsn)], 1.1)
      |> update(context, options)
    end
    def update_vsn(entity, _,_), do: entity

    #--------------------------------
    #
    #--------------------------------
    def update_vsn!(%{vsn: 1.0} = entity, context, options) do
      entity
      |> put_in([Access.key(:payment_type)], :gift)
      |> put_in([Access.key(:details)], %{})
      |> put_in([Access.key(:status_updated_on)], DateTime.utc_now())
      |> put_in([Access.key(:vsn)], 1.1)
      |> update!(context, options)
    end
    def update_vsn!(entity, _,_), do: entity

    #--------------------------------
    # @todo add update_vsn in scaffolding lib.
    #--------------------------------
    def post_get_callback(entity, context, options) do
      entity |> update_vsn(context, options) |> super(context, options)
    end
    def post_get_callback!(entity, context, options) do
      entity |> update_vsn!(context, options) |> super(context, options)
    end

    defp existing_or_new_customer(user, type, context) do
      cond do
        customer = Jetzy.User.Payment.Provider.Account.Repo.by_user!(user, type, context) ->
          {:ok, customer}
        :else ->
          # Create Stripe account if none exists.
          Jetzy.User.Payment.Provider.Account.Repo.new!(user, type, context)
      end
    end

    def confirm_checkout(user, type = :stripe, subscription, session, context, options \\ nil) do
      with {:ok, subscription} <- Jetzy.User.Subscription.Entity.entity_ok!(subscription) do
        # todo confirm session was approved to avoid hackers giving themselves freebies.
        sub = subscription
              |> put_in([Access.key(:details), :stripe_subscription], session.subscription)
              |> put_in([Access.key(:status)], :active)
              |> put_in([Access.key(:status_updated_on)], DateTime.utc_now())
              |> put_in([Access.key(:coverage_start)], DateTime.utc_now())
              |> Jetzy.User.Subscription.Repo.update!(context)
        
        with {:ok, user_id} <- sub && Jetzy.User.Entity.id_ok(sub.user),
             {:ok, u} <- Data.Context.get(Data.Schema.User, user_id) do
             # Set jetzy select
             Data.Context.update(Data.Schema.User, u, %{jetzy_select_status: :approved})
        end
        
        sub && {:ok, sub} || {:error, :update_failed}
      end
    end
    
    
    def stripe_coupon_code(referral_code, _, _) do
      case referral_code do
        {:ref, Jetzy.Payment.Coupon.Entity, "sel50"} ->
          # after referral code is verified we proceed to look up the the appropriate stripe coupon code.
          # this is temporarily hard coded for e2e testing.
          case Application.get_env(:api, ApiWeb.Endpoint)[:environment] do
            :prod -> {:ok, "uesJhyUE"}
            _ ->  {:ok, "nJqMMXIi"}
          end
        _ -> {:ok, nil}
      end
    end
    
    def begin_checkout(user, type = :stripe, subscription, referral_code, context, options \\ nil) do
      with {:ok, customer} <- existing_or_new_customer(Jetzy.User.Entity.ref(user), type, context),
           {:ok, user_sref} <- Jetzy.User.Entity.sref_ok(user),
           {:ok, subscription_definition} <- Jetzy.Subscription.Entity.entity_ok!(subscription),
           {:ok, payment_details} <- Jetzy.Subscription.Entity.payment_details(subscription_definition, type, context, options),
           sub_id <- Jetzy.User.Subscription.Repo.generate_identifier(),
           :ok <- sub_id && :ok || {:error, {:subscription, :generated_identifier}},
           {:ok, sub_sref} <- Jetzy.User.Subscription.Entity.sref_ok(sub_id),
           base_url <- Jetzy.Email.Helper.select_website(),
           :ok <- base_url && :ok || {:error, {:select, :base_url_not_set}},
           {:ok, coupon_code} <- stripe_coupon_code(referral_code, context, options),
           subscription_data <- coupon_code && put_in(payment_details.subscription_data, [:coupon], coupon_code) || payment_details.subscription_data,
           pass_thru <- "session_id={CHECKOUT_SESSION_ID}&user=#{user_sref}&sub=#{sub_sref}",
           session_params <- %{
             customer: customer.account,
             success_url: "#{base_url}/checkout-confirm?#{pass_thru}",
             cancel_url: "#{base_url}/checkout-cancel?#{pass_thru}",
             subscription_data: subscription_data
           },
           {:ok, session} <- Stripe.Session.create(session_params) do
        s = %Jetzy.User.Subscription.Entity{
              identifier: sub_id,
              user: Noizu.ERP.ref(user),
              subscription_definition: Noizu.ERP.ref(subscription_definition),
              payment_type: :stripe_checkout,
              details: %{
                kind: :stripe_checkout,
                stripe_session: session.id,
                stripe_account: Noizu.ERP.ref(customer),
                stripe_subscription: nil,
                referral_code: referral_code,
                stripe_coupon: coupon_code
              },
              status: :checkout,
              status_updated_on: DateTime.utc_now(),
              coverage_start: nil,
              coverage_end: nil
            } |> create!(Noizu.ElixirCore.CallingContext.system(context), override_identifier: true)
        s && {:ok, {s, session}} || {:error, :create_subscription_error}
      else
        error -> error
      end
    end
    
    
    def existing_group_subscriptions(user, _subscription_group, context) do
      #sg_ref = Noizu.ERP.ref(subscription_group)
      #case Enum.filter(by_user(user), &(&1.subscription_group == sg_ref)) do
      case by_user(user, context) do
        [] -> {false, []}
        v ->
          # check for payment overdue status or active subscriptions
          case Enum.filter(v, &(&1.status in [:active, :payment_overdue, :paused])) do
            [] -> {false, []}
            v ->
              case Enum.filter(v, &(&1.status == :active)) do
                [] ->
                  case Enum.filter(v, &(&1.status == :payment_overdue)) do
                    [] -> {:paused, v}
                    o -> {:overdue, o}
                  end
                a ->
                  {:active, a}
              end
          end
      end
    end
    
    def active_by_user(user, context) do
      Enum.filter(by_user(user, context), fn(e) -> e.status == :active end)
    end

    def by_user(user, _context) do
       with {:ok, user_ref} <- Jetzy.User.Entity.ref_ok(user) do
         JetzySchema.Database.User.Subscription.Table.match!([user: user_ref])
         |> Amnesia.Selection.values()
         |> Enum.map(&(&1.entity))
       else
         _ -> []
       end
    end
    
    def by_stripe_subscription(user, stripe, context) do
      by_user(user, context)
      |> Enum.filter(&(&1.details[:stripe_subscription] == stripe))
      |> case do
           [s|_] -> s
           _ -> nil
         end
    end
    
    
  end
end
