defmodule ApiWeb.Api.Admin.V1_0.AdminCommentView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.Admin.V1_0.AdminCommentView, as: View

  def render("comments.json", %{comments: comments}) do
    comment_data = render_many(comments, View, "comment.json", as: :comment)
    page_data = %{
      total_rows: comments.total_entries,
      page: comments.page_number,
      total_pages: comments.total_pages,
      page_size: comments.page_size
    }
    %{
      data: comment_data, pagination: page_data
    }
  end

  def render("comment.json", %{comment: comment}) do
    %{
      comment: comment.message,
      category: comment.category,
      id: comment.id
    }
  end

  def render("comment.json", %{error: error}) do
    %{error: error}
  end

end