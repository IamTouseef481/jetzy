defmodule ApiWeb.Router.SelectHelper do
  defmacro select_routes do
    quote do
      pipe_through :select
      # Web Hooks
      post "/stripe/event-handler", SelectWeb.SelectController, :stripe_event_handler

      pipe_through :select_csrf
      # Incoming
      get "/select-inbound", SelectWeb.SelectController, :inbound
      get "/logout", SelectWeb.SelectController, :logout

      # Landing Page
      get "/", SelectWeb.SelectController, :home
      get "/wp", SelectWeb.SelectController, :home_wp

      # Account
      get "/account", SelectWeb.SelectController, :account
      post "/account", SelectWeb.SelectController, :account

      # Payment Processing
      post "/checkout-begin", SelectWeb.SelectController, :begin_stripe_checkout
      get "/checkout-cancel", SelectWeb.SelectController, :checkout_cancel
      get "/checkout-confirm", SelectWeb.SelectController, :checkout_confirm

      # Ajax
      post "/api/login", SelectWeb.SelectController, :login_request
      post "/api/sign-up", SelectWeb.SelectController, :signup_request
      post "/api/forgot-password", SelectWeb.SelectController, :forgot_password_request
      post "/api/reset-password", SelectWeb.SelectController, :reset_password_request

      # get "/account/status", SelectWeb.SelectController, :account_status
      # get "/account/payment", SelectWeb.SelectController, :payment
      # get "/account/confirm-payment", SelectWeb.SelectController, :payment_confirmation
      # get "/forgot-password", SelectWeb.SelectController, :forgot_password
      # get "/login", SelectWeb.SelectController, :login
      # post "/login", SelectWeb.SelectController, :login
    end
  end
end

defmodule ApiWeb.Router do
  use ApiWeb, :router
  use Plug.ErrorHandler

  import Plug.BasicAuth
  alias Api.Plugs.Guardian
  require ApiWeb.Router.SelectHelper
  require Logger

  @session_options [
    store: :cookie,
    key: "_jetzy_key",
    signing_salt: "xtVB70j/"
  ]

  # ==============================================================
  # Request Pipelines
  # ==============================================================

  pipeline :authenticated do
    plug Guardian.AuthPipeline
    plug Api.Plugs.CurrentUser
    plug Api.Plugs.Authorize
  end

  pipeline :current_user do
    plug Guardian.AuthPipeline
    plug Api.Plugs.CurrentUser
  end

  pipeline :admin do
    plug Api.Plugs.AdminAuth
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug Api.Plugs.AddImageBaseURL
    plug Casex.CamelCaseDecoderPlug
  end

  pipeline :web do
    plug :accepts, ["html"]
  end

  pipeline :select do
    plug Plug.RequestId
    plug Plug.MethodOverride
    plug Plug.Head
    plug Plug.Session, @session_options
    plug Guardian.SelectPipeline

    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :put_secure_browser_headers
  end

  pipeline :select_csrf do
    plug :protect_from_forgery
  end

  pipeline :jetzy_media do
    plug :accepts, ["json", "multipart/form-data"]
  end

  pipeline :jetzy_admin do
    plug :accepts, ["json", "multipart/form-data"]
  end

  pipeline :jetzy_api do
    plug :accepts, ["json", "multipart/form-data"]
    plug Guardian.AuthPipeline
  end

  pipeline :dashboard do
    plug Plug.Static,
      at: "/",
      from: :jetzy,
      gzip: false,
      only: ~w(css fonts images js favicon.ico robots.txt)

    plug Plug.RequestId
    plug Plug.MethodOverride
    plug Plug.Head
    plug Plug.Telemetry, event_prefix: [:admin, :endpoint]
    plug Plug.Session, @session_options
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :basic_auth, username: "jetzy_admin", password: "fwofseo132"
  end

  pipeline :basic_auth_secured do
    plug :basic_auth, username: "jetzy_admin", password: "fwofseo132"
  end

  # ==============================================================
  # Error Catchall
  # ==============================================================
  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack} = err) do
    Jetzy.Module.Telemetry.Request.uncaught_error(conn, err)

    # Todo rate limit database setting (mnesia) with FastGlobal Backing
    cond do
      :rand.uniform(100) <= 5 ->
        Logger.warn("*** Uncaught Error #{inspect(err, pretty: true)}")

      :else ->
        Logger.info("*** Uncaught Error [...]")
    end

    conn
  rescue
    _e -> conn
  catch
    :exit, _e -> conn
    _e -> conn
  end

  # ==============================================================
  # Select Routes
  # ==============================================================

  # --------------------------------------
  # Todo - use match and sub module for handling select paths outside of api folder, as in elixir-backend repo.
  # --------------------------------------

  scope "/", host: "dev-select.jetzy.com" do
    ApiWeb.Router.SelectHelper.select_routes()
  end

  scope "/", host: "stage-select.jetzy.com" do
    ApiWeb.Router.SelectHelper.select_routes()
  end

  scope "/", host: "select.jetzy.com" do
    ApiWeb.Router.SelectHelper.select_routes()
  end

  # ==============================================================
  # Dashboard Routes
  # ==============================================================

  # -----------------------
  # Live Dashboard
  # -----------------------
  import Phoenix.LiveDashboard.Router

  scope "/" do
    pipe_through :dashboard

    live_dashboard "/dashboard",
      ecto_repos: [Data.Repo],
      ecto_psql_extras_options: [long_running_queries: [threshold: "200 milliseconds"]],
      metrics: JetzyWeb.Telemetry
  end

  # ==============================================================
  # Website Routes
  # ==============================================================

  scope "/", ApiWeb do
    pipe_through :web
    get "/", JetzyWebController, :home
    get "/downloadapp.html", JetzyWebController, :download
    get "/about-the-app.html", JetzyWebController, :home
    get "/JetzyAppFaq.html", JetzyWebController, :faq
    get "/Splash/SplashRequest", JetzyWebController, :home
    get "/termsofuse.html", JetzyWebController, :termsofuse
    get "/privacy.html", JetzyWebController, :privacy
    get "/Career/SaveCareer", JetzyWebController, :career
    get "/careers", JetzyWebController, :career

    get "/verify-email/:verification_token", EmailVerificationController, :verify_email

    get "/account/delete", EmailVerificationController, :delete
    post "/account/delete", EmailVerificationController, :confirm_delete
  end

  # ==============================================================
  # Swagger Routes
  # ==============================================================

  # -----------------------
  # Swagger
  # -----------------------
  scope "/api/docs" do
    pipe_through :basic_auth_secured

    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :api,
      disable_validator: true,
      swagger_file: "swagger.json"
  end

  # ==============================================================
  # API Routes
  # ==============================================================

  # -----------------------
  # API Version 1.0
  # -----------------------
  scope "/api/v1.0/admin", ApiWeb do
    pipe_through [:api, :authenticated, :admin]

    put "/user/:user/select/subscriptions/grant",
        Api.Admin.V1_0.AdminSelectController,
        :grant_select

    get "/select/sign-ups", Api.Admin.V1_0.AdminSelectController, :index_sign_ups
    put "/select/sign-ups/:id/approve", Api.Admin.V1_0.AdminSelectController, :approve_sign_up

    #   Admin Settings & Privileges
    get "/list-users", Api.Admin.V1_0.AdminController, :list_users
    get "/user-detail", Api.Admin.V1_0.AdminController, :user_detail
    get "/list-statuses", Api.Admin.V1_0.AdminController, :list_statuses
    put "/user-status", Api.Admin.V1_0.AdminController, :update_user_active_status
    get "/report-messages-review", Api.V1_0.ReportMessagesController, :list_report_messages
    get "/public-interest/:id", Api.Admin.V1_0.AdminController, :make_interest_public
    post "/post-influences", Api.Admin.V1_0.AdminController, :post_influences
    put "/post/:id/post-influences", Api.Admin.V1_0.AdminController, :post_influences_by_id

    resources "/admin-interest", Api.V1_0.AdminInterestController,
      only: [:index, :create, :update, :delete]

    resources "/admin-posts", Api.V1_0.AdminPostController,
      only: [:index, :create, :update, :delete]

    resources "/admin-reward-offers", Api.V1_0.AdminRewardOfferController,
      only: [:index, :create, :update, :delete, :show]

    get "/list-reward-tiers", Api.V1_0.AdminRewardOfferController, :list_reward_tiers

    post "/upload-message-csv", Api.Admin.V1_0.AdminController, :upload_message_csv
    get "messages", Api.Admin.V1_0.AdminController, :messages
    get "get-follow-status", Api.Admin.V1_0.AdminController, :get_follow_status
    get "comment-categories", Api.Admin.V1_0.AdminController, :comment_categories
    get "max-comments-likes", Api.Admin.V1_0.AdminController, :max_comments_likes

    resources "captions", Api.Admin.V1_0.AdminCaptionController, [
      :index,
      :create,
      :update,
      :delete,
      :show
    ]

    post "upload-user-csv", Api.Admin.V1_0.AdminController, :upload_user_csv

    resources "/admin-rewards", Api.V1_0.AdminRewardController,
      only: [:index, :create, :update, :delete, :show]

    resources "influencer-comments", Api.Admin.V1_0.AdminCommentController

    # User Controller
    put "/users/status", Api.Admin.V1_0.UserController, :set_user_status

    get "/users/:user/user-verification-request",
        Api.Admin.V1_0.UserController,
        :user_verification_request

    put "/users/:user/user-verification-request",
        Api.Admin.V1_0.UserController,
        :update_user_verification_request
  end

  # ------
  # Unauthenticated Endpoints
  # -----------------------
  scope "/api/v1.0", ApiWeb.Api.V1_0 do
    pipe_through :api

    # Versioning
    get "/client/:type/version/:version/upgrade-check", ReleaseController, :upgrade_check

    #    Session
    post "/validate-referral-code", UserController, :validate_referral
    post "/sign-up", UserController, :create
    post "/sign-in", UserController, :sign_in
    post "/direct-sign-in", UserController, :direct_sign_in

    get "/verification-request", UserController, :user_verification_request
    put "/verification-request", UserController, :update_user_verification_request

    #   User send email to admin if their account is deactivated
    post "/request-reactivate-account", UserController, :request_admin_to_reactivate_account
    post "/forget-password", UserController, :forget_password
    delete "/guest/:device_token/preferences", UserController, :delete_guest_account
    post "/guest/timeline", PostController, :index_for_guest
    post "/guest/nearby-users", UserController, :nearby_users_for_guest
    post "/map-posts", PostController, :map_posts
    post "/social-sign-up", SocialAuthController, :social_sign_up
    get "/guest/user-events", UserEventController, :index_for_guest
    get "/guest/user-events/:id", UserEventController, :guest_show
    get "/guest/get-interest-events", UserEventController, :get_guest_interest_events
    get "/guest/interests", InterestController, :index_for_guest
    get "/guest/interests-feed", InterestController, :interests_feed_guest
    resources "/guest/guest-interest", GuestInterestController, only: [:show, :create]
    #    post "/user-email-verification", UserController, :user_email_verification
    get "/guest/post/:post_id/comments", CommentController, :guest_index
    get "/guest/posts/:id", PostController, :show_guest_post
    get "/guest/comments/:parent_sref/replies", CommentReplyController, :guest_index
    #   View Who Liked a Post or Comment
    get "/list-likes", LikeController, :list_likes
  end

  # ------
  # Authenticated Endpoints
  # -----------------------
  scope "/api/v1.0", ApiWeb.Api.V1_0 do
    pipe_through [:api, :authenticated]

    #####################################################
    ################## Auth Endpoints ###################
    #####################################################
    # All protected routes here

    #    Select APIs
    put "/select/:type/concierge/booking", SelectController, :begin_booking_flow
    put "/select/:type/concierge/question", SelectController, :begin_question_flow
    put "/select/:type/concierge/request", SelectController, :begin_request_flow

    put "/active-user/feedback", UserController, :log_user_feedback
    delete "/active-user/account", UserController, :begin_account_deletion

    # Activate or deactivate account
    put "/deactivate-user-account", UserController, :deactivate_user_account

    #    User Complete Signup
    post "/complete-signup", UserController, :complete_signup

    #    Posts | Timeline to match with previous API
    get "/posts-search", PostController, :index
    post "/timeline", PostController, :index
    get "/timeline", PostController, :index
    get "/personal-post-feed", PostController, :personal_post_feed
    resources "/posts", PostController, only: [:show, :create, :update, :delete]
    #    Roles
    resources "/roles", RoleController, only: [:index, :show, :create, :update, :delete]
    #    Resources
    resources "/resources", ResourceController, only: [:index, :show, :create, :update, :delete]
    #    Permissions
    get "/roles/:ids/permissions", PermissionController, :index

    resources "/permissions", PermissionController, only: [:create, :update, :delete]
    #    UserRoles
    resources "/user-roles", UserRoleController, only: [:show, :create, :delete]
    #    File Uploading
    #    resources "/image-uploads", ImageUploadController, only: [:index, :show, :create, :update, :delete]
    #    Comments
    resources "/post/:post_id/comments", CommentController,
      only: [:index, :show, :create, :update, :delete]

    #    Comment Replies
    resources "/comments/:parent_sref/replies", CommentReplyController,
      only: [:index, :show, :create, :update, :delete]

    #    Shoutout Types
    resources "/post-types", PostTypeController, only: [:index, :show, :create, :update, :delete]
    #    User
    post "/user", UserController, :update
    #    User Profile
    post "/user-profile-update", UserController, :update_profile
    get "/user-profile/:id", UserController, :show
    #   User referred
    get "user-referred", UserController, :user_referred
    #    Nearby Users
    post "/nearby-users", UserController, :nearby_users
    #   User Image
    post "/add-user-image", UserController, :add_user_profile_image
    put "/sort-profile-images", UserController, :sort_profile_images
    delete "/delete-user-image", UserController, :delete_user_profile_image
    post "/update-user-location", UserController, :update_user_location
    #    User Blocks
    resources "/user-blocks", UserBlockController, only: [:index]
    post "/user-blocks", UserBlockController, :block_unblock_user
    #   User Settings
    get "/user-settings", UserSettingController, :show_user_settings
    put "/user-settings", UserSettingController, :update
    #    LogOut User
    get "/logout", UserController, :logout

    delete "/delete-user", UserController, :delete_user
    #    Invite User
    post "/invite-user", UserController, :invite_user
    #    FAQs
    resources "/faqs", FrequentlyAskedQuestionController,
      only: [:index, :show, :create, :update, :delete]

    #    Admin
    #    post "/update-status", UserController, :update_status
    #   Rewards
    get "/redeemed-reward-history", RewardOfferController, :redeemed_reward_history
    get "/total-reward-points", RewardOfferController, :total_points
    get "/redeem-reward/:id", RewardOfferController, :redeem_reward
    resources "/reward-offers", RewardOfferController, only: [:index, :show]
    #   User-Friends
    resources "/friend", UserFriendController, only: [:create, :show]
    #    User-Follows
    resources "/follow", UserFollowController, only: [:index, :create, :show, :update, :delete]
    get "/follow-request-list", UserFollowController, :show_current_user_follow_requests_list
    post "/accept-decline-request", UserFollowController, :accept_or_decline_follow_request
    #   Interests
    resources "/interests", InterestController, only: [:index, :show, :create, :update, :delete]
    post "/add-interest-users", InterestController, :add_interest_users
    get "/get-interest-users", InterestController, :get_interest_users
    get "/get-interest-topics", InterestController, :get_interest_topics
    get "/interests-feed", InterestController, :interests_feed
    post "/interest-invite", InterestController, :send_interest_invite
    get "/private-user-interest", InterestController, :private_user_interest_list
    #   User Interests
    get "/user-interests", InterestController, :user_interests_list
    post "/user-interests", InterestController, :save_user_interests
    post "/accept-interest-request", InterestController, :accept_interest_request
    #   Verify User Image
    post "/verify-user-image", UserController, :verify_user_image

    # User Cities
    resources "/user-city", UserCountryController, only: [:create, :delete]

    # User Events
    resources "/user-events", UserEventController,
      only: [:index, :show, :create, :update, :delete]

    get "events", UserEventControllers, :events
    get "/user-events-attendees/:id", UserEventController, :user_event_attendees
    post "/user-events-add-attendee", UserEventController, :user_event_add_attendee
    get "/personal-user-events", UserEventController, :personal_user_events
    get "/get-interest-events", UserEventController, :get_interest_events
    delete "/remove-event-attendee", UserEventController, :delete_event_attendee

    # likes on User event comments and their replies
    #    delete "/user-event-likes", UserEventCommentLikesController, :unlike_comment_or_reply

    # User Favorite
    resources "/user-favourite", UserFavoriteController,
      only: [:index, :create, :update, :show, :delete]

    post "/ask-for-recommendation", UserFavoriteController, :ask_for_recommendation
    get "/nearby-recommendations", UserFavoriteController, :nearby_recommendations
    get "/user-recommendations", UserFavoriteController, :user_recommendations
    # User Chats
    post "/start-user-chat", UserChatController, :start_user_chat
    get "/user-chats", UserChatController, :user_chats
    post "/send-invite", UserChatController, :send_invite_of_room
    post "/add-invited-user-in-room", UserChatController, :add_user_in_room_with_referrer_code
    get "/user-room-chat", UserChatController, :user_room_chat
    delete "/room-user", UserChatController, :delete
    delete "/room-message", UserChatController, :delete_message
    resources "/room-user", UserChatController, only: [:create]
    delete "/delete-user-chat", UserChatController, :delete_user_chat
    post "/start-group-chat", UserChatController, :start_group_chat
    put "/update-group-chat/:id", UserChatController, :update_group_chat
    get "/users-for-chat", UserChatController, :users_for_chat
    get "/selective-users-for-chat", UserChatController, :selective_users_for_chat
    get "/chat-group-detail/:room_id", UserChatController, :show_room_detail
    post "/make-group-admin", UserChatController, :make_group_admin
    get "/room-users", UserChatController, :show_room_users

    #   Interest Topics
    resources "/interest-topics", InterestTopicController,
      only: [:show, :create, :update, :delete]

    get "/interest-topic-list/:interest_id", InterestTopicController, :index
    get "/chat-group-members", InterestTopicController, :chat_group_members
    #   User Sync Contacts
    post "/sync-contacts", UserController, :sync_contacts
    #   Post Like
    post "/like", LikeController, :like_post
    #   Comment Like
    post "/user-event-likes", LikeController, :like_unlike_comment_or_reply
    #    post "/shoutout-comment-like", LikeController, :like_comment
    #   Add Jetpoints
    post "/add-jetpoints", RewardOfferController, :add_jetpoints

    # Report Message
    resources "/report-messages", ReportMessagesController,
      only: [:index, :show, :create, :update, :delete]

    # Push Notification
    resources "/notification-status", PushNotificationController,
      only: [:index, :show, :create, :update, :delete]

    get "/report-source", ReportMessagesController, :list_report_source

    # Verify user profile image for chat screen
    post "/verify-image", UserController, :verify_user_profile

    # Update and get Notification Setting
    resources "/notification-setting", NotificationSettingController, only: [:index, :update]
  end

  scope "/api/v1.1", ApiWeb.Api.V1_1 do
    pipe_through [:api, :current_user]
    get "/notifications", PushNotificationController, :index
    get "/notifications/meta", PushNotificationController, :meta_data
    put "/notifications/:ref/clear", PushNotificationController, :clear
    put "/notifications/:ref/read", PushNotificationController, :read
    post "/sign-up", UserController, :create
  end

  if Application.get_env(:api, :tanbits_shim)[:include_vnext] do
    # -----------------------------------------------------
    # Jetzy 2.0 Api
    # -----------------------------------------------------
    scope "/api/v2.0", JetzyApi.V2_0 do
      put "/authenticate", User.Controller, :authenticate
      put "/reauthenticate", User.Controller, :reauthenticate
      put "/logout", User.Controller, :logout

      pipe_through :jetzy_api

      # ===---
      # Query
      # ===---
      get "/query/:index", Query.Controller, :basic_query
      put "/query/:index", Query.Controller, :advanced_query

      # ===---
      # Active User
      # ===---
      get "/active-user", ActiveUser.Controller, :show
      put "/active-user", ActiveUser.Controller, :update

      get "/active-user/settings", ActiveUser.Controller, :index_settings
      put "/active-user/settings", ActiveUser.Controller, :update_settings
      get "/active-user/settings/:setting", ActiveUser.Controller, :get_setting
      put "/active-user/settings/:setting", ActiveUser.Controller, :update_setting

      get "/active-user/followers", ActiveUser.Controller, :get_followers
      get "/active-user/follows", ActiveUser.Controller, :get_follows
      get "/active-user/blocked-users", ActiveUser.Controller, :blocked_users

      # ===---
      # College Majors
      # ===---
      resources "/college-majors", CollegeMajor.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Comments & Replies
      # ===---
      resources "/entity/:subject_sref/comments/:parent_sref/replies", Comment.Controller,
        only: [:index, :show, :create, :update, :delete]

      resources "/entity/:subject_sref/comments", Comment.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Employers
      # ===---
      resources "/employers", Employer.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Entity Images
      # ===---
      resources "/entity/:entity/images", Entity.Image.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Groups
      # ===---
      resources "/groups", Group.Controller, only: [:index, :show, :create, :update, :delete]

      # ===---
      # Images
      # ===---
      resources "/images", Image.Controller, only: [:index, :show, :create, :update, :delete]

      # ===---
      # Image Uploads
      # ===---
      resources "/image-uploads", ImageUpload.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Interests
      # ===---
      resources "/interests", Interest.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Organizations
      # ===---
      resources "/organizations", Organization.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Jetzy Posts
      # ===---
      resources "/posts", Post.Controller, only: [:index, :show, :create, :update, :delete]

      # ===---
      # Locale
      # ===---
      resources "/locale/countries", Locale.Country.Controller,
        only: [:index, :show, :create, :update, :delete]

      resources "/locale/languages", Locale.Language.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Locations
      # ===---
      resources "/locations", Location.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Locations.City
      # ===---
      resources "/locations/city", Location.City.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Locations.State
      # ===---
      resources "/locations/state", Location.State.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Locations.Country
      # ===---
      resources "/locations/country", Location.Country.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Locations.Places
      # ===---
      resources "/locations/places", Location.Place.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Schools
      # ===---
      resources "/schools", School.Controller, only: [:index, :show, :create, :update, :delete]

      # ===---
      # Users
      # ===---
      resources "/users", User.Controller, only: [:index, :show]
      put "/users/:id/follow", User.Controller, :follow_user
      delete "/users/:id/follow", User.Controller, :unfollow_user
      put "/users/:id/block", User.Controller, :block_user
      delete "/users/:id/block", User.Controller, :unblock_user
      put "/users/:id/silence", User.Controller, :silence_user
      delete "/users/:id/silence", User.Controller, :unsilence_user

      # ===---
      # Vocations
      # ===---
      resources "/vocations", Vocation.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Content Flag
      # ===---
      resources "/entity/:subject/flags", Content.Flag.Controller,
        only: [:index, :show, :create, :update, :delete]

      # ===---
      # Reaction
      # ===---
      put "/entity/:subject/reactions/:reaction", Reaction.Controller, :set_reaction
      delete "/entity/:subject/reactions/:reaction", Reaction.Controller, :remove_reaction

      # ===---
      # referrals
      # ===---
      get "/referral-code/", Referral.Controller, :index
      put "/referral-code/generate", Referral.Controller, :generate_code
      get "/referral-code/:code/available", Referral.Controller, :available
      put "/referral-code/:code/register", Referral.Controller, :register
      put "/referral-code/:code/claim", Referral.Controller, :claim
      get "/referral-code/:id/referrals", Referral.Controller, :referrals
      put "/referral-code/:id/enable", Referral.Controller, :enable_code
      put "/referral-code/:id/disable", Referral.Controller, :disable_code

      # ===---
      # reservations - Supports all reservation types using internal identifiers
      # ===---
      get "/reservations", Reservation.Controller, :list_reservations
      post "/reservations", Reservation.Controller, :make_reservation
      get "/reservations/:reservation", Reservation.Controller, :get_reservation
      put "/reservations/:reservation/cancel", Reservation.Controller, :cancel_reservation
      put "/reservations/:reservation/modify", Reservation.Controller, :modify_reservation
    end

    # -----------------------------------------------------
    # Admin API
    # -----------------------------------------------------
    scope "/api/v2.0/admin", JetzyApi.V2_0.Admin do
      pipe_through :jetzy_admin
      resources "/images", Image.Controller, only: [:index, :show, :create, :update, :delete]

      resources "/moderation", Moderation.Controller,
        only: [:index, :show, :create, :update, :delete]

      resources "/posts", Post.Controller, only: [:index, :show, :create, :update, :delete]
      resources "/users", User.Controller, only: [:index, :show, :create, :update, :delete]
    end

    # =====================================================
    # Documents
    # =====================================================
    scope "/api/v2.0/media", JetzyApi.V2_0.Media do
      pipe_through :jetzy_media
      # images accepts query params to specify desired resolution/size and (future) format.
      get "/images/:id/version/:version", Image.Controller, :show_version
      resources "/images", Image.Controller, only: [:create, :update, :show, :delete]

      put "/image-sort", Image.Upload.Controller, :sort
      resources "/image-upload", Image.Upload.Controller, only: [:create, :update, :show, :delete]
      put "/image-upload/:id/set-main", Image.Upload.Controller, :set_main
      put "/image-upload/:id/rename", Image.Upload.Controller, :rename
      put "/image-upload/:id/resize", Image.Upload.Controller, :resize

      # videos accepts query params to specify desired resolution/size and (future) format.
      get "/videos/:id/version/:version", Video.Controller, :show_version
      resources "/videos", Video.Controller, only: [:create, :update, :show, :delete]

      get "/document/:id/version/:version", Document.Controller, :show_version
      resources "/document", Document.Controller, only: [:create, :update, :show, :delete]
    end
  end

  # -----------------------
  # Deprecated
  # -----------------------
  scope "/api/admin", ApiWeb.Api.Admin.V1_0 do
    pipe_through [:api, :authenticated, :admin]

    #   Admin Settings & Privileges
    put "/set-status/:status/:value", AdminController, :set_user_status
    get "/list-users", AdminController, :list_users
    get "/user-detail", AdminController, :user_detail
    put "/user-status", AdminController, :update_user_active_status
    get "/report-messages-review", ReportMessagesController, :list_report_messages
    get "/public-interest/:id", AdminController, :make_interest_public
  end

  scope "/api", ApiWeb.Api.V1_0 do
    pipe_through :api

    #####################################################
    ################## UnAuth Endpoints #################
    #####################################################
    #    Session
    post "/validate-referral-code", UserController, :validate_referral
    post "/sign-up", UserController, :create
    post "/sign-in", UserController, :sign_in
    post "/direct-sign-in", UserController, :direct_sign_in
    #   User send email to admin if their account is deactivated
    post "/request-reactivate-account", UserController, :request_admin_to_reactivate_account
    post "/forget-password", UserController, :forget_password
    # @TODO should be GuestController
    post "/guest/timeline", PostController, :index_for_guest
    post "/map-posts", PostController, :map_posts
    post "/guest/nearby-users", UserController, :nearby_users_for_guest
    post "/social-sign-up", SocialAuthController, :social_sign_up
    get "/guest/user-events", UserEventController, :index_for_guest
    get "/guest/get-interest-events", UserEventController, :get_guest_interest_events
    get "/guest/interests", InterestController, :index_for_guest
    get "/guest/interests-feed", InterestController, :interests_feed_guest
    resources "/guest/guest-interest", GuestInterestController, only: [:show, :create]
    #    post "/user-email-verification", UserController, :user_email_verification
    get "/guest/post/:post_id/comments", CommentController, :guest_index
    get "/guest/comments/:parent_sref/replies", CommentReplyController, :guest_index
    #   View Who Liked a Post or Comment
    get "/list-likes", LikeController, :list_likes
  end

  scope "/api", ApiWeb.Api.V1_0 do
    pipe_through [:api, :authenticated]

    #####################################################
    ################## Auth Endpoints ###################
    #####################################################
    # All protected routes here

    #    User Complete Signup
    post "/complete-signup", UserController, :complete_signup

    #    Posts | Timeline to match with previous API
    get "/posts-search", PostController, :index
    post "/timeline", PostController, :index
    get "/personal-post-feed", PostController, :personal_post_feed
    resources "/posts", PostController, only: [:show, :create, :update, :delete]
    #    Roles
    resources "/roles", RoleController, only: [:index, :show, :create, :update, :delete]
    #    Resources
    resources "/resources", ResourceController, only: [:index, :show, :create, :update, :delete]
    #    Permissions
    get "/roles/:ids/permissions", PermissionController, :index

    resources "/permissions", PermissionController, only: [:create, :update, :delete]
    #    UserRoles
    resources "/user-roles", UserRoleController, only: [:show, :create, :delete]
    #    File Uploading
    #    resources "/image-uploads", ImageUploadController, only: [:index, :show, :create, :update, :delete]
    #    Comments
    resources "/post/:post_id/comments", CommentController,
      only: [:index, :show, :create, :update, :delete]

    #    Comment Replies
    resources "/comments/:parent_sref/replies", CommentReplyController,
      only: [:index, :show, :create, :update, :delete]

    #    Shoutout Types
    resources "/post-types", PostTypeController, only: [:index, :show, :create, :update, :delete]
    #    User
    post "/user", UserController, :update
    #    User Profile
    post "/user-profile-update", UserController, :update_profile
    get "/user-profile/:id", UserController, :show
    #    Nearby Users
    post "/nearby-users", UserController, :nearby_users
    #   User Image
    post "/add-user-image", UserController, :add_user_profile_image
    put "/sort-profile-images", UserController, :sort_profile_images
    delete "/delete-user-image", UserController, :delete_user_profile_image

    #    User Blocks
    resources "/user-blocks", UserBlockController, only: [:index]
    post "/user-blocks", UserBlockController, :block_unblock_user
    #   User Settings
    get "/user-settings", UserSettingController, :show_user_settings
    put "/user-settings", UserSettingController, :update
    #    LogOut User
    get "/logout", UserController, :logout

    delete "/delete-user", UserController, :delete_user
    #    Invite User
    post "/invite-user", UserController, :invite_user
    #    FAQs
    resources "/faqs", FrequentlyAskedQuestionController,
      only: [:index, :show, :create, :update, :delete]

    #    Admin
    #    post "/update-status", UserController, :update_status
    #   Rewards
    get "/redeemed-reward-history", RewardOfferController, :redeemed_reward_history
    get "/total-reward-points", RewardOfferController, :total_points
    get "/redeem-reward/:id", RewardOfferController, :redeem_reward

    resources "/reward-offers", RewardOfferController,
      only: [:index, :show, :create, :update, :delete]

    #   User-Friends
    resources "/friend", UserFriendController, only: [:create, :show]
    #    User-Follows
    resources "/follow", UserFollowController, only: [:index, :create, :show, :update, :delete]
    get "/follow-request-list", UserFollowController, :show_current_user_follow_requests_list
    post "/accept-decline-request", UserFollowController, :accept_or_decline_follow_request
    #   Interests
    resources "/interests", InterestController, only: [:index, :show, :create, :update, :delete]
    post "/add-interest-users", InterestController, :add_interest_users
    get "/get-interest-users", InterestController, :get_interest_users
    get "/get-interest-topics", InterestController, :get_interest_topics
    get "/interests-feed", InterestController, :interests_feed
    post "/interest-invite", InterestController, :send_interest_invite
    #   User Interests
    get "/user-interests", InterestController, :user_interests_list
    post "/user-interests", InterestController, :save_user_interests
    post "/accept-interest-request", InterestController, :accept_interest_request
    #   Verify User Image
    post "/verify-user-image", UserController, :verify_user_image

    # User Cities
    resources "/user-city", UserCountryController, only: [:create, :delete]

    # User Events
    resources "/user-events", UserEventController,
      only: [:index, :show, :create, :update, :delete]

    get "/user-events-attendees/:id", UserEventController, :user_event_attendees
    post "/user-events-add-attendee", UserEventController, :user_event_add_attendee
    get "/personal-user-events", UserEventController, :personal_user_events
    get "/get-interest-events", UserEventController, :get_interest_events
    delete "/remove-event-attendee", UserEventController, :delete_event_attendee

    # likes on User event comments and their replies
    #    delete "/user-event-likes", UserEventCommentLikesController, :unlike_comment_or_reply

    # User Favorite
    resources "/user-favourite", UserFavoriteController,
      only: [:index, :create, :update, :show, :delete]

    # User Chats
    post "/start-user-chat", UserChatController, :start_user_chat
    get "/user-chats", UserChatController, :user_chats
    post "/send-invite", UserChatController, :send_invite_of_room
    post "/add-invited-user-in-room", UserChatController, :add_user_in_room_with_referrer_code
    get "/user-room-chat", UserChatController, :user_room_chat
    delete "/room-user", UserChatController, :delete
    delete "/room-message", UserChatController, :delete_message
    resources "/room-user", UserChatController, only: [:create]
    delete "/delete-user-chat", UserChatController, :delete_user_chat
    post "/start-group-chat", UserChatController, :start_group_chat
    put "/update-group-chat/:id", UserChatController, :update_group_chat
    get "/users-for-chat", UserChatController, :users_for_chat

    #   Interest Topics
    resources "/interest-topics", InterestTopicController,
      only: [:show, :create, :update, :delete]

    get "/interest-topic-list/:interest_id", InterestTopicController, :index
    get "/chat-group-members", InterestTopicController, :chat_group_members
    #   User Sync Contacts
    post "/sync-contacts", UserController, :sync_contacts
    #   Post Like
    post "/like", LikeController, :like_post
    #   Comment Like
    post "/user-event-likes", LikeController, :like_unlike_comment_or_reply
    #    post "/shoutout-comment-like", LikeController, :like_comment
    #   Add Jetpoints
    post "/add-jetpoints", RewardOfferController, :add_jetpoints

    # Report Message
    resources "/report-messages", ReportMessagesController,
      only: [:index, :show, :create, :update, :delete]

    # Push Notification
    resources "/notification-status", PushNotificationController,
      only: [:index, :show, :create, :update, :delete]

    get "/report-source", ReportMessagesController, :list_report_source

    # Verify user profile image for chat screen
    post "/verify-image", UserController, :verify_user_profile

    # Update and get Notification Setting
    resources "/notification-setting", NotificationSettingController, only: [:index, :update]
  end
end
