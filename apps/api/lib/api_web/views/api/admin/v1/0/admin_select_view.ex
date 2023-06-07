defmodule ApiWeb.Api.Admin.V1_0.AdminSelectView do
  @moduledoc false
  use ApiWeb, :view
  alias Data.Context

  def render("sign_ups.json", %{entries: entries}) do
    list = render_many(entries.entries, ApiWeb.Api.Admin.V1_0.AdminSelectView, "sign-up.json", as: :entry)
    page_data = %{
      total_rows: entries.total_entries,
      page: entries.page_number,
      total_pages: entries.total_pages,
      page_size: entries.page_size
    }
    %{data: list, pagination: page_data}
  end

  def render("sign-up.json", %{entry: entry}) do
    entry
  end

end
