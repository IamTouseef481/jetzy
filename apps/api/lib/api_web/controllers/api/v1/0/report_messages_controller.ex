#-------------------------------------------------------------------------------
# Author: Tanbits <dev@tanbits.com>, Keith Brings <keith.brings@noizu.com>
# Copyright (C) 2022 Travellers Connect, inc. All rights reserved.
#-------------------------------------------------------------------------------

defmodule ApiWeb.Api.V1_0.ReportMessagesController do
  @moduledoc """
  Manage message reporting.
  """

  #============================================================================
  # Uses, Requires, Aliases
  #============================================================================
  import Ecto.Query, warn: false
  use ApiWeb, :controller
  use PhoenixSwagger
  use Filterable.Phoenix.Controller

  alias Data.Context
  alias Data.Context.ReportMessages
  alias ApiWeb.Utils.Common
  alias Data.Context
  alias Data.Schema.{ReportMessage, UserShoutout, UserEvent, User, Comment}

  #============================================================================
  # filterable
  #============================================================================
  filterable do

    filter report_source(query, value, _conn) do
      query
      |> where([rm], rm.report_source_id == ^value)
    end


  end

  #============================================================================
  # Controller Actions
  #============================================================================

  #----------------------------------------------------------------------------
  # create/2
  #----------------------------------------------------------------------------
  swagger_path :create do
    post("/v1.0/report-messages")
    summary("Create Report Message")
    description("It will Create a new Report Message and deactivate the user to be reported.")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      body(:body, Schema.ref(:CreateReportMessage), "Create Report Message params", required: true)
    end

    response(200, "Ok", Schema.ref(:ReportMessage))
  end

  @doc """
  Create message content report and deactivate user.
  """
  def create(conn, %{"report_source_id" => source, "item_id" => item_id} = params) do
    %{id: user_id, first_name: first_name, email: email} = current_user = Api.Guardian.Plug.current_resource(conn)
    with nil <- Context.get_by(ReportMessage, [item_id: item_id, user_id: user_id, is_deleted: false]),
         {:ok , report_message} <- Context.create(ReportMessage, Map.merge(params, %{"user_id" =>  user_id})),
         message <-  get_report_message_string(report_message, current_user),
          admin_email_params <- get_email_params(source, item_id, message),
         _data <-
          # Email To Amins
           Enum.map(ReportMessages.get_admins_email, fn email ->
            Api.Mailer.send_report_message_email(
               %{email: email, first_name: message},
               admin_email_params
             )
           end),
           # Email To User
           Api.Mailer.send_report_message_email(
               %{email: email, first_name: first_name},
               %{message: message}
             )
      do
      #Check that if report is against user then check the number of reports against this user. if 3 then deactivate user
      if ReportMessages.get_report_message_count_by_source_and_item_id(source, item_id) == 3 do
        case verify_source(source, item_id) do
          {:ok, _data} -> render(conn, "show.json", %{report_message: report_message})
          {:error, error} -> render(conn, "error.json", %{error: error})
        end
        else
        render(conn, "show.json", %{report_message: report_message})
      end
    else
      %ReportMessage{} -> render(conn, "error.json", %{error: "A request from the user already exists"})
      {:error, %Ecto.Changeset{} = changeset} -> render(conn, "error.json", %{error: Common.decode_changeset_errors(changeset)})
      {:error, _} -> render(conn, "error.json", %{error: ["Error in Sending email"]})
    end
  end
  def create(conn, _) do
    render(conn, "error.json", %{error: ["Invalid Params"]})
  end


  #----------------------------------------------------------------------------
  # index/2
  #----------------------------------------------------------------------------
  swagger_path :index do
    get("/v1.0/report-messages")
    summary("Get Report Message")
    description("Get Report Message")
    produces("application/json")
    security([%{Bearer: []}])

    response(200, "Ok", Schema.ref(:ReportMessage))
  end

  @doc """
  List active message reports.
  """
  def index(conn, _params) do
    %{id: user_id} = Api.Guardian.Plug.current_resource(conn)
    case ReportMessages.get_report_message(user_id) do
      report_message -> render(conn, "report_messages.json", %{report_messages: report_message})
    end
  end

  #----------------------------------------------------------------------------
  # list_report_messages/2
  #----------------------------------------------------------------------------
  swagger_path :list_report_messages do
    get("/v1.0/admin/report-messages-review")
    summary("Get list of Report Message")
    description("Get list of Report Message. This is for admin only")
    produces("application/json")
    security([%{Bearer: []}])

    parameters do
      page(:query, :integer, "page No", required: true)
      page_size(:query, :integer, "page size", required: false)
      report_source(:query, :string, "shoutout, user, event")
    end

    response(200, "Ok", Schema.ref(:ListReportMessages))
  end

  @doc """
  Admin User list report messages.
  @todo this should be moved into an admin controller.
  """
  def list_report_messages(conn, %{"page" => page} = params) do
    page_size = params["page_size"] || 200
    with {:ok, query, _filter_values} <- apply_filters(ReportMessage, conn),
         report_message <- ReportMessages.list_report_messages(query, page, page_size) do
          render(conn, "report_messages_admin.json", %{report_messages: report_message})
    end
  end

  #----------------------------------------------------------------------------
  # list_report_source/2
  #----------------------------------------------------------------------------
  swagger_path :list_report_source do
    get("/v1.0/report-source")
    summary("Get Report Source")
    description("Get Report Source")
    produces("application/json")
    security([%{Bearer: []}])

    response(200, "Ok", Schema.ref(:ReportSource
    ))
  end

  @doc """
  Return list of report sources.
  """
  def list_report_source(conn, _params) do
    case ReportMessages.get_sources_report do
      report_source -> render(conn, "report_source.json", %{report_sources: report_source})
    end
  end

  #============================================================================
  # Internal Methods
  #============================================================================

  #----------------------------------------------------------------------------
  # verify_source/2
  #----------------------------------------------------------------------------
#  @doc """
#  helpers like this should be moved into domain objects for testability/reusability.
#  """

  defp get_email_params(source, item_id, message) do
    if String.downcase(source) == "user" do
      user = Context.get(User, item_id)
      %{message: message, profile_link: user && user.shareable_link || nil}
      else
      %{message: message}
    end
  end

  defp verify_source(source, item_id) do
    case String.trim(source) |> String.downcase() do
      "user" -> deactivate_user(item_id, "User")
      "shoutout" -> deactivate_user(item_id, "UserShoutout")
      "event" -> deactivate_user(item_id, "UserEvent")
      "comment" -> deactivate_user(item_id, "Comment")
      "comment_reply" -> deactivate_user(item_id, "CommentReply")
      "interest" -> deactivate_user(item_id, "Interest")
      _ -> {:error, "Invalid Source ID"}
    end
  end

  #----------------------------------------------------------------------------
  # deactivate_user/2
  #----------------------------------------------------------------------------
#  @doc """
#  helpers like this should be moved into domain objects for testability/reusability.
#  """
  defp deactivate_user(item_id, schema) do
    case schema do
      "User" -> update_user_status(item_id)
      "UserEvent" ->
        case Context.get(UserEvent, item_id) do
          %{user_id: user_id} -> update_user_status(user_id)
          _ -> {:error, "Something went wrong"}
        end
      "UserShoutout" ->
        case Context.get(UserShoutout, item_id) do
          %{user_id: user_id} -> update_user_status(user_id)
          _ -> {:error, "Something went wrong"}
        end
      "Comment" ->
        case Context.get(Comment, item_id) do
          %{user_id: user_id} -> update_user_status(user_id)
          _ -> {:error, "Something went wrong"}
        end
      "CommentReply" ->
        case Context.get(Comment, item_id) do
          %{user_id: user_id} -> update_user_status(user_id)
          _ -> {:error, "Something went wrong"}
        end
      "Interest" -> {:ok, ["not needed to update interest right now"]}
    end
  end

  #----------------------------------------------------------------------------
  # update_user_status/2
  #----------------------------------------------------------------------------
#  @doc """
#  helpers like this should be moved into domain objects for testability/reusability.
#  """
  defp update_user_status(user_id) do
    with %User{is_deactivated: is_deactivated, is_self_deactivated: is_self_deactivated, is_deleted: is_deleted} = user <- Context.get(User, user_id),
         false <- is_deactivated or is_deleted or is_self_deactivated,
         {:ok, data} <- Context.update(User, user, %{is_deactivated: true}) do
          {:ok, data}
        else
          nil -> {:error, "User does not exist"}
          true -> {:error, "User deleted or already deactivated"}
          {:error, changeset} -> {:error, Common.decode_changeset_errors(changeset)}
          _ -> {:error, "Something went wrong"}
    end
  end

  #----------------------------------------------------------------------------
  # get_report_message_string/2
  #----------------------------------------------------------------------------
  @doc """
  @todo just use inline string interpolation. "\#{var}"
  """
  def get_report_message_string(report_message, current_user) do
    cond do
        report_message.report_source_id == "user" ->
        case Context.get(User, report_message.item_id) do
          nil -> "Reported"
          data -> (current_user.first_name || "") <> " " <> (current_user.last_name || "") <> " Reported " <> (data.first_name || "") <> " " <> (data.last_name || "")
        end

      report_message.report_source_id == "event" ->
        case Context.get(UserEvent, report_message.item_id) do
          nil -> "Reported"
          data -> (current_user.first_name || "") <> " " <> (current_user.last_name || "") <> " Reported " <> (data.description || "")
        end

      report_message.report_source_id == "shoutout" ->
        case Context.get(UserShoutout, report_message.item_id) do
          nil -> "Reported"
          data -> (current_user.first_name || "" ) <> " " <> (current_user.last_name || "") <> " Reported " <> (data.title || "")
        end

      report_message.report_source_id == "comment" ->
        case Context.get(Comment, report_message.item_id) do
          nil -> "Reported"
          data -> (current_user.first_name || "") <> " " <> (current_user.last_name || "") <> " Reported " <> (data.description || "")
        end

      report_message.report_source_id == "comment_reply" ->
        case Context.get(Comment, report_message.item_id) do
          nil -> "Reported"
          data -> (current_user.first_name || "") <> " " <> (current_user.last_name || "") <> " Reported " <> (data.description || "")
        end
      true -> "Reported"
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
      ReportMessage:
        swagger_schema do
          title("Report Message")
          description("Report Message Response")

          example(%{
            response_data: %{
              reportSourceId: "user",
              user_id: "a711bf85-963f-42ed-9728-c2047d5694fb",
              id: "a711bf85-963f-42ed-9728-c2047d5694fb",
              itemId: "82606fa5-129c-448c-95cf-cbfc19d89790",
              description: "This is a first description test 123"
            }
          })
        end,
      ReportSource:
        swagger_schema do
          title("Report Source")
          description("Report Source Response")

          example(%{
            response_data: %{
              id: "user",
              name: "User"
            }
          })
        end,
      ListReportMessages:
        swagger_schema do
          title("Report Message")
          description("Report Message Response")

          example(%{
            data: %{
              reportSourceId: "user",
              user: %{
                  userImage: "20a6f452-4dca-4c89-9ede-0002c621168b--637070709605545548--97df1b3e-9a0b-4475-8cf7-4b5356b4829d",
                  userId: "a711bf85-963f-42ed-9728-c2047d5694fb",
                  lastName: "Admin",
                  isActive: true,
                  imageThumbnail: "null",
                  firstName: "Super",
                  baseUrl: "https://d1exz3ac7m20xz.cloudfront.net/"
              },
              id: "a711bf85-963f-42ed-9728-c2047d5694fb",
              itemId: "82606fa5-129c-448c-95cf-cbfc19d89790",
              description: "This is a first description test 123"
            },
            pagination: %{
              totalRows: 3,
              totalPages: 1,
              page: 1
            }
          })
        end,
      CreateReportMessage:
        swagger_schema do
          title("Update Report Message")
          description("Update Report Message")

          properties do
            description(:string, "Report Message")
            item_id(:string, "Item ID")
            report_source_id(:string, "Report Source ID")
          end

          example(%{
            description: "This is a first description test",
            item_id: "82606fa5-129c-448c-95cf-cbfc19d89791",
            report_source_id: "user OR user_event OR user_shoutout"
          })
        end
    }
  end
end
