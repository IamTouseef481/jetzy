defmodule Data.Context.InfluencerMessages do
  import Ecto.Query, warn: false

  alias Data.Repo
  #  alias Data.Context
  alias Data.Schema.InfluencerMessage

  def paginate_messages(%{type: type, search: search, page: page, page_size: page_size}) do
    InfluencerMessage
    |> where([m], m.type == ^type)
    |> where([m], fragment("? ilike ?", m.message, ^"#{search}%"))
    |> Repo.paginate(%{page: page, page_size: page_size})
  end

  def paginate_messages(%{type: type, page: page, page_size: page_size}) do
    InfluencerMessage
    |> where([m], m.type == ^type)
    |> Repo.paginate(%{page: page, page_size: page_size})
  end

  def paginate_comment_categories(page, page_size) do
    InfluencerMessage
    |> where([im], im.type == ^"comment" and not is_nil(im.category))
    |> distinct([im], im.category)
    |> select([im], im.category)
    |> Repo.paginate(%{page: page, page_size: page_size})
  end

  def get_comments_count_by_categories(categories) do
    InfluencerMessage
    |> where([im], im.type == ^"comment" and im.category in ^categories)
    |> select([im], count(im.id))
    |> Repo.one
  end

  def get_comments_by_category(categories, count) do
    InfluencerMessage
    |> where([im], im.type == ^"comment" and im.category in ^categories)
    |> order_by(fragment("RANDOM()"))
    |> limit(^count)
    |> select([im], im.message)
    |> Repo.all()
  end

end
