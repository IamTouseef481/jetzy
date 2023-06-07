defmodule ApiWeb.Api.V1_0.ReportMessagesView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.V1_0.ReportMessagesView
  alias Data.Context.ReportMessages

  def render("show.json", %{report_message: report_message}) do
    %{
      user_id: report_message.user_id,
    report_source_id: report_message.report_source_id,
    item_id: report_message.item_id,
    description: report_message.description,
    id: report_message.id
    }
  end
  def render("report_messages.json", %{report_messages: report_messages}) do
    report_message_data = render_many(report_messages, ReportMessagesView, "show.json", as: :report_message)
    %{data: report_message_data}
  end

  def render("report_messages_admin.json", %{report_messages: report_messages}) do
    report_message_data = render_many(report_messages.entries, ReportMessagesView, "report_message_admin.json", as: :report_message)
    page_data = %{
      total_rows: report_messages.total_entries,
      page: report_messages.page_number,
      total_pages: report_messages.total_pages,
      page_size: report_messages.page_size
    }
    %{data: report_message_data, pagination: page_data}
  end
   def render("report_message_admin.json", %{report_message: report_message}) do
       %{
          user: ApiWeb.Api.V1_0.UserView.render("user.json", %{user: report_message.user}),
          report_source_id: report_message.report_source_id,
          item_id: report_message.item_id,
          description: report_message.description,
          id: report_message.id
       }
    end
  def render("error.json", %{error: error}) do
    %{error: error}
  end

  def render("show_report_source.json", %{report_source: report_source}) do
    %{
      id: report_source.id,
      name: report_source.name
    }
  end
  def render("report_source.json", %{report_sources: report_sources}) do
    report_source_data = render_many(report_sources, ReportMessagesView, "show_report_source.json", as: :report_source)
    %{data: report_source_data}
  end
end
