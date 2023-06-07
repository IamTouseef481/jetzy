# -------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
# -------------------------------------------------------------------------------

defmodule SelectWeb.SelectController do
  @moduledoc false
  alias Api.Router.Helpers, as: Routes
  # ============================================================================
  # Uses, Requires, Aliases
  # ============================================================================
  use ApiWeb, :controller
  import JetzyWeb.Helpers
  alias Api.Guardian

  alias ApiWeb.Utils.Common

  import SelectWeb.SelectView

  # ============================================================================
  # Web Hooks
  # ============================================================================

  @webhook_secret Application.get_env(:api, :stripe)[:webhook_secret]

  @subscription_status %{
    "trialing" => :active,
    "incomplete" => :pending,
    "incomplete_expired" => :expired,
    "active" => :active,
    "past_due" => :payment_overdue,
    "canceled" => :canceled,
    "unpaid" => :payment_overdue
  }

  @doc """
  @todo handle incoming stripe web hooks for payment cancellations, renewals, etc.
  @see https://stripe.com/docs/billing/subscriptions/webhooks
  """
  def stripe_event_handler(conn, params) do
    context = Noizu.ElixirCore.CallingContext.system()
    [stripe_sig | _] = get_req_header(conn, "stripe-signature")
    payload = conn.private[:raw_body]

    with {:ok, event} <- Stripe.Webhook.construct_event(payload, stripe_sig, @webhook_secret) do
      case event.type do
        "customer.subscription.updated" ->
          update_user_subscription_status(event, context)

        "customer.subscription.pending_update_expired" ->
          update_user_subscription_status(event, context)

        "customer.subscription.pending_update_applied" ->
          update_user_subscription_status(event, context)

        "customer.subscription.deleted" ->
          update_user_subscription_status(event, context)

        _ ->
          :ok
      end
    end

    conn
    |> JetzyWeb.Helpers.api_response(%{outcome: true}, Noizu.ElixirCore.CallingContext.system())
  end

  def update_user_subscription_status(event, context) do
    subscription_code = event.data.object.id
    customer_code = event.data.object.customer

    with subscription_status <- @subscription_status[event.data.object.status],
         :ok <- (subscription_status && :ok) || {:error, :unsupported_status},
         account <-
           Jetzy.User.Payment.Provider.Account.Repo.by_account(customer_code, :stripe, context),
         :ok <- (account && :ok) || {:error, :account_not_found},
         sub <-
           Jetzy.User.Subscription.Repo.by_stripe_subscription(
             account.user,
             subscription_code,
             context
           ),
         :ok <- (sub && :ok) || {:error, :sub_not_found} do
      if sub.status != subscription_status do
        %Jetzy.User.Subscription.Entity{sub | status: subscription_status}
        |> Jetzy.User.Subscription.Repo.update!(context)
      end
    end
  end

  # ============================================================================
  # Ajax Calls
  # ============================================================================
  def forgot_password_request(conn, params) do
    context = Noizu.ElixirCore.CallingContext.system()

    case Data.Context.OTPTokens.create_request(params["email"]) do
      {:ok, {user, otp_token}} ->
        case Api.Mailer.send_forget_password_email(user, "#{otp_token.otp}") do
          {:error, _} ->
            conn
            |> put_status(401)
            |> JetzyWeb.Helpers.api_response(
              %{outcome: false, message: "Internal Error"},
              context
            )

          {:ok, _} ->
            conn
            |> JetzyWeb.Helpers.api_response(%{outcome: true}, context)
        end

      {:error, :not_found} ->
        conn
        |> put_status(401)
        |> JetzyWeb.Helpers.api_response(
          %{outcome: false, message: "User Does not Exist"},
          context
        )

      {:error, _} ->
        conn
        |> put_status(401)
        |> JetzyWeb.Helpers.api_response(%{outcome: false, message: "Internal Error"}, context)
    end
  end

  def reset_password_request(conn, params) do
    context = Noizu.ElixirCore.CallingContext.system()
    otp = (is_binary(params["otp"]) && String.to_integer(params["otp"])) || params["otp"]
    password = params["password"]
    email = params["email"]

    with :ok <- (otp && :ok) || {:error, :otp_required},
         :ok <- (password && :ok) || {:error, :otp_required},
         :ok <- (email && :ok) || {:error, :otp_required},
         {:ok, {user, otp_token}} <- Data.Context.OTPTokens.valid_code(email, otp),
         {:ok, user} =
           Data.Context.update(Data.Schema.User, user, %{password: Bcrypt.hash_pwd_salt(password)}),
         {:ok, jwt, _} <- Guardian.encode_and_sign(user) do
      Data.Context.update(Data.Schema.OTPToken, otp_token, %{
        last_forget_password_at: DateTime.utc_now()
      })

      conn
      |> Guardian.Plug.remember_me_from_token(jwt)
      |> JetzyWeb.Helpers.api_response(
        %{outcome: true, jwt: jwt, user: user.id},
        Noizu.ElixirCore.CallingContext.system()
      )
    else
      {:error, :code_not_found} ->
        conn
        |> put_status(401)
        |> JetzyWeb.Helpers.api_response(%{outcome: false, message: "Invalid Code"}, context)

      {:error, :code_invalid} ->
        conn
        |> put_status(401)
        |> JetzyWeb.Helpers.api_response(%{outcome: false, message: "Invalid Code"}, context)

      {:error, :not_found} ->
        conn
        |> put_status(401)
        |> JetzyWeb.Helpers.api_response(
          %{outcome: false, message: "User Does not Exist"},
          context
        )

      _ ->
        conn
        |> put_status(401)
        |> JetzyWeb.Helpers.api_response(%{outcome: false, message: "Internal Error"}, context)
    end
  end

  def signup_request(conn, params) do
    context = Noizu.ElixirCore.CallingContext.system()
    options = []

    age =
      case params["age"] do
        v when is_integer(v) -> v
        v when is_bitstring(v) -> String.to_integer(v)
        _ -> nil
      end

    params =
      cond do
        age ->
          dob = DateTime.utc_now() |> Timex.shift(years: -age)

          params
          |> Map.put("dob", dob)
          |> Map.put("dob_full", "#{dob.year}")

        :else ->
          params
      end

    with {:ok, {user, params}} <- Data.Context.Users.register_user(params, context, options),
         {:ok, jwt, _} <- Guardian.encode_and_sign(user) do
      # Sign Up Points
      ApiWeb.Utils.Common.update_points(user.id, :sign_up_1000)

      # Update Analytics
      Jetzy.Module.Telemetry.Analytics.select_registration(conn, user)

      # Schedule Push notification if incomplete profile
      if Data.Schema.User.incomplete_profile?(user) do
        ApiWeb.Utils.PushNotification.schedule_push_notification(:profile_reminder, user)
      end

      # response
      conn
      |> Guardian.Plug.remember_me_from_token(jwt)
      |> JetzyWeb.Helpers.api_response(
        %{outcome: true, jwt: jwt, user: user.id},
        Noizu.ElixirCore.CallingContext.system()
      )
    else
      {:ok, %{message: message}} ->
        conn
        |> put_status(403)
        |> JetzyWeb.Helpers.api_response(
          %{outcome: false, message: message},
          Noizu.ElixirCore.CallingContext.system()
        )

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_status(403)
        |> JetzyWeb.Helpers.api_response(
          %{outcome: false, message: "An internal error occurred. Try again later."},
          Noizu.ElixirCore.CallingContext.system()
        )

      {:error, message} ->
        conn
        |> put_status(403)
        |> JetzyWeb.Helpers.api_response(
          %{outcome: false, message: message},
          Noizu.ElixirCore.CallingContext.system()
        )
    end
  end

  def login_request(conn, params) do
    email = params["email"]
    password = params["password"]
    # Context.update(User, user, %{password: hash_pwd_salt(password)})
    with {:ok, user, jwt} <-
           Data.Context.Users.login_by_email_and_pass(email, password, ttl: {1, :hours}) do
      conn
      |> Guardian.Plug.remember_me_from_token(jwt)
      |> JetzyWeb.Helpers.api_response(
        %{outcome: true, jwt: jwt, user: user.id},
        Noizu.ElixirCore.CallingContext.system()
      )
    else
      _ ->
        conn
        |> put_status(403)
        |> JetzyWeb.Helpers.api_response(
          %{outcome: false, message: "Invalid Credentials"},
          Noizu.ElixirCore.CallingContext.system()
        )
    end
  end

  # ============================================================================
  # Redirects
  # ============================================================================
  def inbound(conn, %{"jwt" => jwt} = params) do
    ttl = {1, :hours}
    context = Noizu.ElixirCore.CallingContext.system()
    src = conn.query_params["src"]
    strategy = conn.query_params["stg"]

    with {:ok, claims} <- Api.Guardian.decode_and_verify(jwt, %{}, []),
         {:ok, user} <- Api.Guardian.resource_from_claims(claims),
         {:ok, user_ref} <- Jetzy.User.Entity.ref_ok(user),
         {:ok, jwt} <- Api.Guardian.encode_and_sign(user, %{}, ttl: ttl) do
      conn =
        conn
        |> apply_referral_code(params)
        |> put_session(:user, user.id)
        |> put_session(:src, src)
        |> put_session(:stategy, strategy)
        |> Guardian.Plug.remember_me_from_token(jwt)

      # check for existing subscriptions. (currently only select).
      case Jetzy.User.Subscription.Repo.existing_group_subscriptions(user_ref, :select, context) do
        {false, _} ->
          conn
          |> redirect(to: Routes.select_path(conn, :home))

        _ ->
          conn
          |> redirect(to: "/account")
      end
    else
      _ ->
        conn =
          conn
          |> apply_referral_code(params)
          |> put_session(:src, src)
          |> put_session(:stategy, strategy)
          |> redirect(to: Routes.select_path(conn, :home))
    end
  end

  def inbound(conn, params) do
    txn = conn.query_params["txn"]
    src = conn.query_params["src"]
    strategy = conn.query_params["stg"]
    ttl = {1, :hours}
    context = Noizu.ElixirCore.CallingContext.system()

    with {:ok, txn} <- txn && Base.url_decode64(txn),
         {:ok, user} <- Data.Schema.User.entity_ok!(txn),
         {:ok, user_ref} <- Jetzy.User.Entity.ref_ok(user),
         {:ok, jwt} <- Api.Guardian.encode_and_sign(user, %{}, ttl: ttl) do
      conn =
        conn
        |> apply_referral_code(params)
        |> put_session(:txn, txn)
        |> put_session(:user, user.id)
        |> put_session(:src, src)
        |> put_session(:stategy, strategy)
        |> Guardian.Plug.remember_me_from_token(jwt)

      # check for existing subscriptions. (currently only select).
      case Jetzy.User.Subscription.Repo.existing_group_subscriptions(user_ref, :select, context) do
        {false, _} ->
          conn
          |> redirect(to: Routes.select_path(conn, :home))

        _ ->
          conn
          |> redirect(to: "/account")
      end
    else
      _ ->
        conn =
          conn
          |> apply_referral_code(params)
          |> put_session(:src, src)
          |> put_session(:stategy, strategy)
          |> redirect(to: Routes.select_path(conn, :home))
    end
  end

  def begin_stripe_checkout(conn, params) do
    context = Noizu.ElixirCore.CallingContext.system()
    referral_code = active_referral_code(conn, context)

    if current_user = Guardian.Plug.current_resource(conn) do
      with {:ok, user_entity} <- Jetzy.User.Entity.entity_ok!(current_user),
           sub_type <- Jetzy.Subscription.Repo.by_handle("select-standard"),
           :ok <- (sub_type && :ok) || {:error, :subscription_type_not_found},
           {:ok, {_, session}} <-
             Jetzy.User.Subscription.Repo.begin_checkout(
               user_entity,
               :stripe,
               sub_type,
               referral_code,
               context
             ) do
        conn
        |> redirect(external: session.url)
      else
        error ->
          IO.inspect(error, label: :session_failed)
          render(conn, "sign-up-error.html", layout: {ApiWeb.LayoutView, "bootstrap.app.html"})
      end
    else
      conn
      |> redirect(to: "/")
    end
  end

  def checkout_confirm(conn, params) do
    context = Noizu.ElixirCore.CallingContext.system()

    with {:ok, sub_sref} <-
           (params["sub"] && {:ok, params["sub"]}) || {:error, {:subscription, :not_provided}},
         {:ok, sess_id} <-
           (params["session_id"] && {:ok, params["session_id"]}) ||
             {:error, {:stripe, :session_id_not_provided}},
         {:ok, sub} <- Jetzy.User.Subscription.Entity.entity_ok!(sub_sref),
         {:ok, checkout} <- Stripe.Session.retrieve(sess_id),
         {:ok, sub} <-
           Jetzy.User.Subscription.Repo.confirm_checkout(
             params["user"],
             :stripe,
             sub,
             checkout,
             context
           ) do
      with {:ok, user_id} <- Jetzy.User.Entity.id_ok(sub.user) do
        ApiWeb.Endpoint.broadcast("backend:#{user_id}", "refresh-cache", %{subject: "active-user"})
      end

      # @todo this is conditional depending if the user came from app or the website. Text must be changed if coming from website.
      render(conn, "sign-up.html", layout: {ApiWeb.LayoutView, "bootstrap.app.html"})
    else
      e ->
        IO.inspect(e, label: :checkout_error)

        render(conn, "confirmation-error.html", %{
          sub: params["sub"],
          sess_id: params["session_id"],
          layout: {ApiWeb.LayoutView, "bootstrap.app.html"}
        })
    end
  end

  def checkout_cancel(conn, params) do
    IO.inspect(params, label: :cancel)
    context = Noizu.ElixirCore.CallingContext.system()

    with {:ok, sub_sref} <-
           (params["sub"] && {:ok, params["sub"]}) || {:error, {:subscription, :not_provided}},
         {:ok, sub} <- Jetzy.User.Subscription.Entity.entity_ok!(sub_sref) do
      # @TODO confirm caller is authorized to delete.
      # @TODO confirm sess id matches.
      Jetzy.User.Subscription.Repo.delete!(sub.identifier, context)
    end

    conn
    |> redirect(to: "/account")
  end

  def logout(conn, params) do
    conn
    |> Guardian.Plug.sign_out(clear_remember_me: true)
    |> clear_referral_code(params)
    |> put_resp_cookie("beta", "true")
    |> redirect(to: "/")
  end

  # ============================================================================
  # Landing Page
  # ============================================================================
  def home(conn, params) do
    txn =
      cond do
        txn = get_session(conn, :txn) ->
          txn

        txn = conn.query_params["txn"] ->
          case Base.url_decode64(txn) do
            {:ok, txn} -> txn
            _ -> txn
          end

        :else ->
          nil
      end

    src = get_session(conn, :src) || conn.query_params["src"]
    strategy = get_session(conn, :strategy) || conn.query_params["stg"]
    token = get_csrf_token()
    flash = %{info: get_flash(conn, :info), error: get_flash(conn, :error)}

    google_client_id = get_google_client_id()
    apple_client_id = get_apple_client_id()

    cond do
      current_user = Guardian.Plug.current_resource(conn) ->
        name = "#{current_user.first_name} #{current_user.last_name}"

        conn
        |> apply_referral_code(params)
        |> render("home.html", %{
          jetzy_website: Jetzy.Email.Helper.website(),
          account: name,
          txn: txn,
          src: src,
          strategy: strategy,
          csrf_token: token,
          flash: flash,
          google_client_id: google_client_id,
          apple_client_id: apple_client_id,
          layout: {ApiWeb.LayoutView, "select.app.html"}
        })

      :else ->
        conn
        |> apply_referral_code(params)
        |> render("home.html", %{
          jetzy_website: Jetzy.Email.Helper.website(),
          account: nil,
          txn: txn,
          src: src,
          strategy: strategy,
          csrf_token: token,
          flash: flash,
          google_client_id: google_client_id,
          apple_client_id: apple_client_id,
          layout: {ApiWeb.LayoutView, "select.app.html"}
        })
    end
  end

  def home_wp(conn, params) do
    txn =
      cond do
        txn = get_session(conn, :txn) ->
          txn

        txn = conn.query_params["txn"] ->
          case Base.url_decode64(txn) do
            {:ok, txn} -> txn
            _ -> txn
          end

        :else ->
          nil
      end

    src = get_session(conn, :src) || conn.query_params["src"]
    strategy = get_session(conn, :strategy) || conn.query_params["stg"]
    token = get_csrf_token()

    cond do
      user = get_session(conn, :user) ->
        with {:ok, user} <- Data.Schema.User.entity_ok!(user) do
          name = "#{user.last_name}, #{user.first_name}"

          render(conn, "user_home.html", %{
            name: name,
            txn: txn,
            src: src,
            strategy: strategy,
            csrf_token: token
          })
        else
          _ ->
            render(conn, "home.wp.html", %{
              txn: txn,
              src: src,
              strategy: strategy,
              csrf_token: token
            })
        end

      :else ->
        conn
        |> render("home.wp.html", %{
          txn: txn,
          src: src,
          strategy: strategy,
          csrf_token: token,
          layout: {ApiWeb.LayoutView, "select.html"}
        })
    end
  end

  # ============================================================================
  # Account Pages
  # ============================================================================
  def account(conn, params) do
    cond do
      current_user = Guardian.Plug.current_resource(conn) ->
        context = Noizu.ElixirCore.CallingContext.system()

        with {:ok, user_ref} <- Jetzy.User.Entity.ref_ok(current_user) |> IO.inspect(label: :ref),
             {:ok, user} <- Jetzy.User.Entity.entity_ok!(user_ref) |> IO.inspect(label: :entity) do
          case Jetzy.User.Subscription.Repo.existing_group_subscriptions(
                 user_ref,
                 :select,
                 context
               ) do
            {false, _} ->
              # app_sign_up__subscription_checkout(user, context, conn, params)
              app_sign_up__subscription_manage(user, nil, context, conn, params)

            {_, subs} ->
              app_sign_up__subscription_manage(user, subs, context, conn, params)
          end
        else
          _ ->
            render(conn, "sign-up-error.html", layout: {ApiWeb.LayoutView, "bootstrap.app.html"})
        end

      :else ->
        conn
        |> redirect(to: "/")
    end
  end

  def app_sign_up__subscription_manage(user, subs, context, conn, _params) do
    token = get_csrf_token()

    current_user = Guardian.Plug.current_resource(conn)
    shareable_link = Common.generate_url("select-jetzy", current_user.id)

    render(conn, "subscription-manage.html", %{
      csrf_token: token,
      user: user,
      subs: subs,
      context: context,
      shareable_link: shareable_link,
      layout: {ApiWeb.LayoutView, "bootstrap.app.html"}
    })
  end

  def referral_code_valid?(code) do
    # todo referral logic
    cond do
      code == "sel50" -> true
      :else -> false
    end
  end

  def apply_referral_code(conn, params) do
    rc = params["select-referral"] || params["select_referral"]

    cond do
      referral_code_valid?(rc) -> put_resp_cookie(conn, "srcode", rc, max_age: 3600)
      :else -> conn
    end
  end

  def clear_referral_code(conn, params) do
    conn
    |> delete_resp_cookie("srcode")
  end

  def active_referral_code(conn, context) do
    # revalidate code
    c = conn.cookies["srcode"]
    # stub for future use
    c && {:ref, Jetzy.Payment.Coupon.Entity, c}
  end

  def get_google_client_id() do
    Application.get_env(:api, :openid_connect_providers)[:google][:app_id]
  end

  def get_apple_client_id() do
    Application.get_env(:api, :openid_connect_providers)[:apple][:discovery_document_uri]
  end
end
