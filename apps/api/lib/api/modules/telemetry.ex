#-------------------------------------------------------------------------------
# Author: Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, Inc. All rights reserved.
#-------------------------------------------------------------------------------
defmodule Jetzy.Module.Telemetry do


  defmodule Analytics do
    use Elixometer


    def select_registration(conn, user) do
      # Log details with Athena S3
      Jetzy.Module.Athena.emit(:select_registration, %{conn: conn, user: user})
  
      # Emit Elixometer
      Elixometer.update_counter("analytics.select.registration", 1)
      NewRelic.report_custom_metric("Analytics/select.registration", 1)
      # Emit :telemetry
      :telemetry.execute([:analytics, :select, :registration], %{count: 1})
      user_registration(conn, user)
    end
    
    def user_registration(conn, user) do
      # Log details with Athena S3
      Jetzy.Module.Athena.emit(:user_registration, %{conn: conn, user: user})

      # Emit Elixometer
      Elixometer.update_counter("analytics.user.registration", 1)
      NewRelic.report_custom_metric("Analytics/user.registration", 1)
      # Emit :telemetry
      :telemetry.execute([:analytics, :user, :registration], %{count: 1})
    end

    def user_registration_complete(conn, user) do
      # Log details with Athena S3
      Jetzy.Module.Athena.emit(:user_registration_complete, %{conn: conn, user: user})

      # Emit Elixometer
      Elixometer.update_counter("analytics.user.registration_complete", 1)
      NewRelic.report_custom_metric("Analytics/user.registration.complete", 1)
      # Emit :telemetry
      :telemetry.execute([:analytics, :user, :registration_complete], %{count: 1})
    end

    def user_follow(conn, user, follow) do
      # Log details with Athena S3
      Jetzy.Module.Athena.emit(:user_follow, %{conn: conn, user: user, follow: follow})

      # Emit Elixometer
      Elixometer.update_counter("analytics.user.follow", 1)
      NewRelic.report_custom_metric("Analytics/user.follow", 1)
      # Emit :telemetry
      :telemetry.execute([:analytics, :user, :follow], %{count: 1})
    end


    def user_unfollow(conn, user, follow) do
      # Log details with Athena S3
      Jetzy.Module.Athena.emit(:user_unfollow, %{conn: conn, user: user, follow: follow})

      # Emit Elixometer
      Elixometer.update_counter("analytics.user.unfollow", 1)
      NewRelic.report_custom_metric("Analytics/user.unfollow", 1)
      
      # Emit :telemetry
      :telemetry.execute([:analytics, :user, :unfollow], %{count: 1})
    end




    def post_created(conn, user, post) do
      # Log details with Athena S3
      Jetzy.Module.Athena.emit(:post_created, %{conn: conn, user: user, post: post})

      # Emit Elixometer
      Elixometer.update_counter("analytics.post.created", 1)

      # Emit :telemetry
      :telemetry.execute([:analytics, :post, :created], %{count: 1})
    end

    def post_favorite(conn, user, post) do
      # Log details with Athena S3
      Jetzy.Module.Athena.emit(:post_favorite, %{conn: conn, user: user, post: post})

      # Emit Elixometer
      Elixometer.update_counter("analytics.post.favorite", 1)

      # Emit :telemetry
      :telemetry.execute([:analytics, :post, :favorite], %{count: 1})
    end

    def comment_created(conn, user, comment) do
      # Log details with Athena S3
      Jetzy.Module.Athena.emit(:comment_created, %{conn: conn, user: user, comment: comment})

      # Emit Elixometer
      Elixometer.update_counter("analytics.comment.created", 1)

      # Emit :telemetry
      :telemetry.execute([:analytics, :comment, :created], %{count: 1})
    end

    def comment_favorite(conn, user, comment) do
      # Log details with Athena S3
      Jetzy.Module.Athena.emit(:comment_favorite, %{conn: conn, user: user, comment: comment})

      # Emit Elixometer
      Elixometer.update_counter("analytics.comment.favorite", 1)

      # Emit :telemetry
      :telemetry.execute([:analytics, :comment, :favorite], %{count: 1})
    end


  end

  defmodule Errors do
  
  
    def query_failure(event, user, error, conn, args) do
      args = put_in(args, [:message], ApiWeb.Utils.Common.decode_changeset_errors(error))
      NewRelic.report_custom_event("#{event}", args)
    end


  end
  
  defmodule Request do
    use Elixometer

    def uncaught_error(conn, error) do
      # Log details with Athena S3
      Jetzy.Module.Athena.emit(:uncaught_request_error, %{conn: conn, error: error})

      # Emit Elixometer
      Elixometer.update_counter("request.error.count", 1)
      
      # Emit :telemetry
      :telemetry.execute([:api_web, :request, :error], %{count: 1})
    end
  end
end