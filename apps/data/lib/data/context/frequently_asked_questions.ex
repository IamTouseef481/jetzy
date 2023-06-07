defmodule Data.Context.FrequentlyAskedQuestions do
  import Ecto.Query, warn: false

  alias Data.Repo
#  alias Data.Context
  alias Data.Schema.FrequentlyAskedQuestion

  @spec preload_all(FrequentlyAskedQuestion.t()) :: FrequentlyAskedQuestion.t()
  def preload_all(data), do: Repo.preload(data, [])

  def list(model, page, page_size \\ 10) do
    Repo.paginate(model, page: page, page_size: page_size)
  end

end
