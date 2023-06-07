#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.SelectController do
  @moduledoc """
  User sign-in, request reactivation, sign-out, search nearby, etc. api calls.
  """
  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false
  use ApiWeb, :controller
  use Filterable.Phoenix.Controller
  use PhoenixSwagger
  require Logger
  import Bcrypt, only: [hash_pwd_salt: 1]
  import Api.Helper.Utils, only: [number: 0]


  @sendgrid_website Application.get_env(:data, :sendgrid)[:website] || "https://jetzy.com"
  @sendgrid_cdn Application.get_env(:data, :sendgrid)[:cdn] || "https://jetzy.com"


  @referral_code_url Application.get_env(:api, :configuration)[:referral_code_url]
  @profile_create_reward "6eb58c08-5a90-4847-9059-f3392cdb550e"

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # begin_booking_flow/2
  #----------------------------------------------------------------------------
  swagger_path :begin_booking_flow do
    put("/v1.0/select/{type}/concierge/booking")
    summary("Trigger email to concierge flow.")
    description("...pending")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      type(:path, :string, "Business type - restaurant, club, hotel, spa, ...", required: true)
      lang(:query, :string, "en-US etc.", required: false)
      body(:body, :object, "business type specific json payload. Must include {vsn: :integer, subject: \"ext.select.{type}@{id}\", \"query\": {}}", required: true)
    end
    response(200, "Ok", Schema.ref(:ConciergeQueueResponse))
  end


  def forward_reservation_request(user, code, details, context, options) do
    template = Noizu.EmailService.V3.Email.Template.Entity.entity!({:jetzy, :reservation})
               |> Noizu.EmailService.V3.Email.Template.Entity.refresh!(Noizu.ElixirCore.CallingContext.system(context))
    final_recipient = %{ref: {:ref, User, user.id}, name: "#{user.last_name}, #{user.first_name}", email: user.email}
    concierge = %{ref: {:ref, User, :system}, name: "Jetzy Select", email: Jetzy.Email.Helper.select_forward()}
    bindings = %{
      user:  %{
        id: user.id,
        profile_picture: "your-image.png",
        name: %{
          first: user.first_name,
          last: user.last_name
        },
        email: user.email,
      },
      reservation: details,
      environment: %{
        locale: "en",
        website: @sendgrid_website,
        cdn: @sendgrid_cdn,
        contact: %{
          email: "contact@jetzy.com",
          name: %{
            first: "Contact",
            last: "Jetzy"
          }
        }
      }
    }
    send_options = %{}

    %Noizu.EmailService.V3.SendGrid.TransactionalEmail{
      template: Noizu.Proto.EmailServiceTemplate.refresh!(template, context),
      recipient: concierge,
      recipient_email: concierge.email,
      sender: %{name: "JetzySelect [#{code}]", email: "concierge+#{code}@jetzy.com", ref: {:ref, User, :system}},
      reply_to: final_recipient,
      bcc: [
        %{name: "Jetzy Concierge", email: "concierge+#{code}@jetzy.com", ref: {:ref, User, :system}},
        %{name: "Jetzy Concierge", email: "keith.brings+select#{code}@noizu.com", ref: {:ref, User, :system}},
      ],
      body: " ",
      html_body: " ",
      subject: " ",
      bindings: bindings,
    } |> Noizu.EmailService.V3.SendGrid.TransactionalEmail.send!(context, send_options)
  end

  @doc """
  kick off request process.
  """
  def begin_booking_flow(conn, %{"type" => type} = params) do
    cond do
      conn.body_params["reject"] ->
        conn
        |> json(%{outcome: false, request_code: "E9938423", subcode: 555,  note: "Service Currently Offline: Please Try Again Later."})
      :else ->
        context = Noizu.ElixirCore.CallingContext.admin()
        with %{id: current_user_id} = user <- Guardian.Plug.current_resource(conn),
        {:ok, user_ref} <- Jetzy.User.Entity.ref_ok(user) do
          reservation = conn.body_params
          res = Jetzy.Select.Reservation.Tracking.Repo.new(user_ref, reservation, context)
                |> Jetzy.Select.Reservation.Tracking.Repo.create!(context)
          reservation = put_in(reservation, [:reservation_code], res.code)
          forward_reservation_request(user, res.code, reservation, context, [])
          conn
          |> json(%{outcome: true, request_code: res.code, subcode: 200,  note: "Your reservation code is #{res.code} (copied to the clipboard). You will receive an email at #{user.email} with reservation details soon. You can reference this code for further communication."})
        end
    end
  end

  #----------------------------------------------------------------------------
  # begin_question_flow/2
  #----------------------------------------------------------------------------
  swagger_path :begin_question_flow do
    put("/v1.0/select/{type}/concierge/question")
    summary("Trigger email to concierge flow.")
    description("...pending")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      type(:path, :string, "Business type - restaurant, club, hotel, spa, ...", required: true)
      lang(:query, :string, "en-US etc.", required: false)
      body(:body, :object, "business type specific json payload. Must include {vsn: :integer, subject: \"ext.select[{type},{id}]\", query: {\"question\": \"\", \"date\": 2019}}", required: true)
    end
    response(200, "Ok", Schema.ref(:ConciergeQueueResponse))
  end
  @doc """
  kick off request process.
  """
  def begin_question_flow(conn, %{"type" => type} = params) do
    cond do
      conn.body_params["reject"] ->
        conn
        |> json(%{outcome: false, request_code: "E9938423",  subcode: 555, note: "Service Currently Offline: Please Try Again Later."})
      :else ->
        conn
        |> json(%{outcome: true, request_code: "RJ9938423",  subcode: 200, note: "You query has been queued and we will get back to you promptly."})
    end
  end


  #----------------------------------------------------------------------------
  # begin_request_flow/2
  #----------------------------------------------------------------------------
  swagger_path :begin_request_flow do
    put("/v1.0/select/{type}/concierge/request")
    summary("Trigger email to concierge flow.")
    description("...pending")
    produces("application/json")
    security([%{Bearer: []}])
    parameters do
      type(:path, :string, "Business type - restaurant, club, hotel, spa, ...", required: true)
      lang(:query, :string, "en-US etc.", required: false)
      request_code(:query, :string, "Request is for existing reservation/booking", required: false)
      body(:body, :object, "business type specific json payload. Must include {vsn: :integer, subject: \"ext.select[{type},{id}]\", query: {\"question\": \"\", \"date\": 2019}}", required: true)
    end
    response(200, "Ok", Schema.ref(:ConciergeQueueResponse))
  end
  @doc """
  kick off request process.
  """
  def begin_question_flow(conn, %{"type" => type} = params) do
    cond do
      conn.body_params["reject"] ->
        conn
        |> json(%{outcome: false, request_code: "E9938423",  subcode: 555, note: "Service Currently Offline: Please Try Again Later."})
      :else ->
        conn
        |> json(%{outcome: true, request_code: "RJ9938423",  subcode: 200, note: "You query has been queued and we will get back to you promptly."})
    end
  end

  #========================================================================
  # Swagger Definition
  #========================================================================
  @doc """
  Swagger MetaData.
  """
  def swagger_definitions do
    %{
      ConciergeQueueResponse:
        swagger_schema do
          title("Generic Select Reservation/Information Query Response")
          description("Simple MVP response type for confirming txn success/failure and providing a TXN code + comment")
          properties do
            outcome(:boolean, "Successfully Queued. Not yet confirmed.")
            request_code(:string, "Uniquely identify request in system for future follow up. Assume 7-12 digit Alphanumeric code")
            note(:string, "Internal Error message explaining failed outcome, or details on timeline")
          end
          example(%{
            outcome: true,
            request_code: "A777JJI",
            note: "You should receive final confirmation via email in the next 200 days."
          })
        end,
    }
  end
end
