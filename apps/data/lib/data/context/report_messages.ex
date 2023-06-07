defmodule Data.Context.ReportMessages do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.{ReportMessage, Admin, ReportSource}

  @spec preload_all(ReportMessage.t()) :: ReportMessage.t()
  def preload_all(data), do: Repo.preload(data, [:report_source])

  def get_report_message(user_id) do
    ReportMessage
    |> where([rm], rm.user_id == ^user_id)
    |> Repo.all()
  end

  def list_report_messages(query, page, page_size) do
    from(q in query)
    |> order_by([q], [desc: q.inserted_at])
    |> preload([:user])
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def get_report_message_count_by_source_and_item_id(report_source_id, item_id) do
    ReportMessage
    |> where([rm], rm.item_id == ^item_id and rm.report_source_id == ^report_source_id)
    |> select([rm], count(rm.id))
    |> Repo.one()
  end

  def get_admins_email do
    Admin
    |> where([a], is_nil(a.deleted_at))
    |> select([a], a.email)
    |> Repo.all
  end

  def get_sources_report do
    ReportSource
    |> Repo.all()
  end

end
