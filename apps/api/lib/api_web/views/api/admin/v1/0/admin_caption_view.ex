defmodule ApiWeb.Api.Admin.V1_0.AdminCaptionView do
  @moduledoc false
  use ApiWeb, :view
  alias ApiWeb.Api.Admin.V1_0.AdminCaptionView, as: View

  #  alias Data.Context.Interests


  def render("captions.json", %{captions: captions}) do
    caption_data = render_many(captions, View, "caption.json", as: :caption)
    page_data = %{
      total_rows: captions.total_entries,
      page: captions.page_number,
      total_pages: captions.total_pages,
      page_size: captions.page_size
    }
    %{
      data: caption_data, pagination: page_data
    }
  end

  def render("caption.json", %{caption: caption}) do
    %{
      caption: caption.message,
      id: caption.id
    }
  end

  def render("caption.json", %{error: error}) do
    %{error: error}
  end

end