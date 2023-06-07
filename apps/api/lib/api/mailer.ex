defmodule Api.Mailer do
#  import SendGrid.Mail
  import SendGrid.Email

  @from_email Application.get_env(:data, :sendgrid)[:sendgrid_from_email]
  @from_name Application.get_env(:data, :sendgrid)[:sendgrid_from_email_name]
  @admin_mail Application.get_env(:data, :sendgrid)[:sendgrid_admin_email]

  def send(
        user,
        subject \\ "Jetzy",
        template,
        data,
        from_email \\ @from_email,
        from_name \\ @from_name
      ) do
    Task.start(fn ->
      SendGrid.Email.build()
      |> SendGrid.Email.add_to(user.email, user.first_name)
      |> SendGrid.Email.put_from(from_email, from_name)
      |> SendGrid.Email.put_subject(subject)
      |> put_phoenix_view(ApiWeb.Api.V1_0.EmailView)
      |> put_phoenix_template(template, data)
      |> SendGrid.Mail.send()
    end)
  end

  def send_forget_password_email(user, code) do
    send(user, "Forget Password | Jetzy", "forget_password_email.html", code: code)
  end

  def send_account_reactivation_email(params) do
    send(%{email: @admin_mail, first_name: "Admin"}, "Request for Account Reactivation",
      "request_account_reactivation.html", [description: params.description], params.from_email, params.user_name)
  end

  def send_verify_email(user, url) do
    send(user, "Please Verify Your Email | Jetzy", "verify_email.html", url: url)
  end

  def send_room_referral_code(user, params) do
    send(user, "Referral Code | Jetzy", "referrer_code.html", params: params)
  end

  def send_invite_user_referral_code(user, params) do
    send(user, "Referral Code | Jetzy", "invite_user_referrer_code.html", params: params)
  end

  def send_report_message_email(user, report_message) do
    send(user, "Report Message| Jetzy", "report_message_email.html", report_message: report_message.message, profile_link: report_message[:profile_link])
  end

  def send_welcome_email(user) do
    send(user, "Welcome to Jetzy", "welcome.html", [])
  end

  def send_email(user, params) do
    send(user, params["subject"]|| params[:subject] || "Jetzy", params.template_name, notification: params.notification)
  end

  def send_email_with_user_link(user, params) do
    send(user, params["subject"] || params[:subject] || "Jetzy", "notification_email_with_user_link.html", data: params)
  end

  def send_interest_public_email(params) do
    send(%{email: @admin_mail, first_name: "Admin"}, "Interest Public Request", params.template_name, notification: params.notification)
  end

  def send_direct_login_email(user) do
    send(user, "Welcome to Jetzy", "direct_login.html", params: %{"direct_login_link" => user.direct_login_link})
  end

  def send_email_deactivation_email(user, params) do
    send(user, "Account Deactivation", params.template_name, notification: params.notification)
  end

  def send_email_of_post_tagging(user, params) do
    send(user, params["subject"]|| params[:subject] || "Jetzy", params.template_name,
      notification: params.notification,
      event_link: params.event_link,
      feed_event_link: params.feed_event_link)
  end

end
